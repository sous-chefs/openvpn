# frozen_string_literal: true

provides :openvpn_user
unified_mode true

default_action :create

property :client_name, String, name_property: true
property :create_bundle, [true, false], default: true
property :force, [true, false], default: false
property :destination, String
property :additional_vars, Hash, default: {}
property :compression, String

# PKI properties (previously from node attributes)
property :key_dir, String, default: '/etc/openvpn/keys'
property :easy_rsa_dir, String, default: '/etc/openvpn/easy-rsa'
property :client_prefix, String, default: 'vpn-prod'
property :template_cookbook, String, default: 'openvpn'

# Key generation defaults
property :ca_expire, Integer, default: 3650
property :key_expire, Integer, default: 3650
property :key_size, Integer, default: 2048
property :key_country, String, default: 'US'
property :key_province, String, default: 'CA'
property :key_city, String, default: 'San Francisco'
property :key_org, String, default: 'Fort Funston'
property :key_email, String, default: 'admin@example.com'

action :create do
  key_dir = new_resource.key_dir
  cert_path = ::File.join(key_dir, "#{new_resource.client_name}.crt")
  ca_cert_path = ::File.join(key_dir, 'ca.crt')
  key_path = ::File.join(key_dir, "#{new_resource.client_name}.key")
  client_file_basename = [new_resource.client_prefix, new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || key_dir)
  bundle_filename = "#{new_resource.client_name}.tar.gz"
  bundle_full_path = ::File.expand_path(::File.join(destination_path, bundle_filename))

  execute "generate-openvpn-#{new_resource.client_name}" do
    command "umask 077 && ./pkitool #{new_resource.client_name}"
    cwd new_resource.easy_rsa_dir
    environment(
      'EASY_RSA' => new_resource.easy_rsa_dir,
      'KEY_CONFIG' => "#{new_resource.easy_rsa_dir}/openssl.cnf",
      'KEY_DIR' => key_dir,
      'CA_EXPIRE' => new_resource.ca_expire.to_s,
      'KEY_EXPIRE' => new_resource.key_expire.to_s,
      'KEY_SIZE' => new_resource.key_size.to_s,
      'KEY_COUNTRY' => new_resource.key_country,
      'KEY_PROVINCE' => new_resource.key_province,
      'KEY_CITY' => new_resource.key_city,
      'KEY_ORG' => new_resource.key_org,
      'KEY_EMAIL' => new_resource.key_email,
      'KEY_OU' => 'OpenVPN Server'
    )
    creates cert_path unless new_resource.force
    notifies :run, 'execute[gencrl]', :immediately
    notifies :create, 'remote_file[/etc/openvpn/crl.pem]', :immediately
  end

  cleanup_name = "cleanup-old-bundle-#{new_resource.client_name}"

  template "#{destination_path}/#{client_file_basename}.conf" do
    source 'client.conf.erb'
    cookbook new_resource.template_cookbook
    variables(
      client_cn: new_resource.client_name,
      compression: new_resource.compression
    )
    notifies :delete, "file[#{cleanup_name}]", :immediately
    only_if { new_resource.create_bundle }
  end

  template "#{destination_path}/#{client_file_basename}.ovpn" do
    source new_resource.create_bundle ? 'client.conf.erb' : 'client-inline.conf.erb'
    cookbook new_resource.template_cookbook
    if new_resource.create_bundle
      variables(
        client_cn: new_resource.client_name,
        compression: new_resource.compression
      )
    else
      sensitive true
      variables(
        lazy do
          {
            client_cn: new_resource.client_name,
            ca: IO.read(ca_cert_path),
            cert: IO.read(cert_path),
            key: IO.read(key_path),
            compression: new_resource.compression,
          }.merge(new_resource.additional_vars) { |_key, oldval, _newval| oldval }
        end
      )
    end
    notifies :delete, "file[#{cleanup_name}]", :immediately
  end

  file cleanup_name do
    action :nothing
    path bundle_full_path
  end

  execute "create-openvpn-tar-#{new_resource.client_name}" do
    cwd destination_path
    filelist = "ca.crt #{new_resource.client_name}.crt #{new_resource.client_name}.key #{client_file_basename}.ovpn"
    filelist += " #{client_file_basename}.conf" if new_resource.create_bundle
    command "umask 077 && tar zcf #{bundle_filename} #{filelist}"
    creates bundle_full_path unless new_resource.force
  end
end

action :delete do
  key_dir = new_resource.key_dir
  client_file_basename = [new_resource.client_prefix, new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || key_dir)
  bundle_filename = "#{new_resource.client_name}.tar.gz"
  bundle_full_path = ::File.expand_path(::File.join(destination_path, bundle_filename))

  %w(conf ovpn).each do |ext|
    file "#{destination_path}/#{client_file_basename}.#{ext}" do
      action :delete
    end
  end

  file bundle_full_path do
    action :delete
    only_if { new_resource.create_bundle }
  end
end
