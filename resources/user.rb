#
# Cookbook:: openvpn
# Resource:: user
#

property :client_name, String, name_property: true
property :create_bundle, [true, false], default: true
property :force, [true, false]
property :destination, String
property :additional_vars, Hash, default: {}
property :key_dir,   String, default: lazy { node['openvpn']['key_dir'] }
property :ca_expire, String, default: lazy { node['openvpn']['key']['ca_expire'].to_s }
property :key_expire, String, default: lazy { node['openvpn']['key']['expire'].to_s }
property :key_size, String, default: lazy { node['openvpn']['key']['size'].to_s }
property :key_country, String, default: lazy { node['openvpn']['key']['country'] }
property :key_province, String, default: lazy { node['openvpn']['key']['province'] }
property :key_city, String, default: lazy { node['openvpn']['key']['city'] }
property :key_org, String, default: lazy { node['openvpn']['key']['org'] }
property :key_email, String, default: lazy { node['openvpn']['key']['email'] }
property :key_org_unit, String, default: 'OpenVPN Server'

unified_mode true

# TODO: this action will not recreate if the client configuration data has
#       changed. Requires manual intervention.

action :create do
  # Setup some variables
  cert_path = ::File.join(new_resource.key_dir, "#{new_resource.client_name}.crt")
  ca_cert_path = ::File.join(new_resource.key_dir, 'ca.crt')
  key_path = ::File.join(new_resource.key_dir, "#{new_resource.client_name}.key")
  client_file_basename = [node['openvpn']['client_prefix'], new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || new_resource.key_dir)
  bundle_filename = "#{new_resource.client_name}.tar.gz"
  bundle_full_path = ::File.expand_path(::File.join(destination_path, bundle_filename))

  execute "generate-openvpn-#{new_resource.client_name}" do
    command "umask 077 && ./pkitool #{new_resource.client_name}"
    cwd '/etc/openvpn/easy-rsa'
    environment(
      'EASY_RSA' => '/etc/openvpn/easy-rsa',
      'KEY_CONFIG' => '/etc/openvpn/easy-rsa/openssl.cnf',
      'KEY_DIR' => new_resource.key_dir,
      'CA_EXPIRE' => new_resource.ca_expire,
      'KEY_EXPIRE' => new_resource.key_expire,
      'KEY_SIZE' => new_resource.key_size,
      'KEY_COUNTRY' => new_resource.key_country,
      'KEY_PROVINCE' => new_resource.key_province,
      'KEY_CITY' => new_resource.key_city,
      'KEY_ORG' => new_resource.key_org,
      'KEY_EMAIL' => new_resource.key_email,
      'KEY_OU' => new_resource.key_org_unit
    )
    creates cert_path unless new_resource.force
    notifies :run, 'execute[gencrl]', :immediately
    notifies :create, "remote_file[#{[node['openvpn']['fs_prefix'], '/etc/openvpn/crl.pem'].join}]", :immediately
  end

  cleanup_name = "cleanup-old-bundle-#{new_resource.client_name}"

  template "#{destination_path}/#{client_file_basename}.conf" do
    source 'client.conf.erb'
    cookbook node['openvpn']['cookbook_user_conf']
    variables(client_cn: new_resource.client_name)
    notifies :delete, "file[#{cleanup_name}]", :immediately
    only_if { new_resource.create_bundle }
  end

  template "#{destination_path}/#{client_file_basename}.ovpn" do
    source new_resource.create_bundle ? 'client.conf.erb' : 'client-inline.conf.erb'
    cookbook node['openvpn']['cookbook_user_conf']
    if new_resource.create_bundle
      variables(client_cn: new_resource.client_name)
    else
      sensitive true
      variables(
        lazy do
          {
            client_cn: new_resource.client_name,
            ca: IO.read(ca_cert_path),
            cert: IO.read(cert_path),
            key: IO.read(key_path),
          }.merge(new_resource.additional_vars) { |key, oldval, newval| oldval } # rubocop:disable Lint/UnusedBlockArgument
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
  key_dir = node['openvpn']['key_dir']
  client_file_basename = [node['openvpn']['client_prefix'], new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || key_dir)
  bundle_filename = "#{new_resource.client_name}.tar.gz"
  bundle_full_path = ::File.expand_path(::File.join(destination_path, bundle_filename))

  %w(conf ovpn).each do |ext|
    file "#{destination_path}/#{client_file_basename}.#{ext}" do
      action :delete
    end
    file bundle_full_path do
      action :delete
      only_if { new_resource.create_bundle }
    end
  end
end
