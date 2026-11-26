# frozen_string_literal: true

provides :openvpn_user
unified_mode true

property :client_name, String, name_property: true
property :create_bundle, [true, false], default: true
property :force, [true, false]
property :destination, [String, nil]
property :key_vars, Hash, default: {}
property :additional_vars, Hash, default: {}
property :key_dir, String, default: '/etc/openvpn/keys'
property :easy_rsa_dir, String, default: '/etc/openvpn/easy-rsa'
property :crl_path, String, default: '/etc/openvpn/crl.pem'
property :message_digest, String, default: 'sha256'
property :client_prefix, String, default: 'vpn-prod'
property :cookbook, String, default: 'openvpn'
property :config, Hash, default: {}
property :gateway, String, default: lazy { node['fqdn'] || 'vpn.example.com' }
property :server_verification, [String, nil]

# TODO: this action will not recreate if the client configuration data has
#       changed. Requires manual intervention.

action :create do
  key_dir = new_resource.key_dir
  cert_path = ::File.join(key_dir, "#{new_resource.client_name}.crt")
  ca_cert_path = ::File.join(key_dir, 'ca.crt')
  key_path = ::File.join(key_dir, "#{new_resource.client_name}.key")
  client_file_basename = [new_resource.client_prefix, new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || key_dir)
  bundle_filename = "#{new_resource.client_name}.tar.gz"
  bundle_full_path = ::File.expand_path(::File.join(destination_path, bundle_filename))
  compression = if new_resource.config['compress']
                  new_resource.config['compress']
                elsif new_resource.config['comp-lzo']
                  'lzo'
                end

  directory destination_path do
    owner 'root'
    group node['root_group']
    mode '0700'
    recursive true
  end

  execute "generate-openvpn-#{new_resource.client_name}" do
    command "umask 077 && ./pkitool #{new_resource.client_name}"
    cwd new_resource.easy_rsa_dir
    environment(
      'EASY_RSA' => new_resource.easy_rsa_dir,
      'KEY_CONFIG' => "#{new_resource.easy_rsa_dir}/openssl.cnf",
      'KEY_DIR' => key_dir,
      'CA_EXPIRE' => (new_resource.key_vars['ca_expire'] || 3650).to_s,
      'KEY_EXPIRE' => (new_resource.key_vars['key_expire'] || 3650).to_s,
      'KEY_SIZE' => (new_resource.key_vars['key_size'] || 2048).to_s,
      'KEY_COUNTRY' => new_resource.key_vars['key_country'] || 'US',
      'KEY_PROVINCE' => new_resource.key_vars['key_province'] || 'CA',
      'KEY_CITY' => new_resource.key_vars['key_city'] || 'San Francisco',
      'KEY_ORG' => new_resource.key_vars['key_org'] || 'Fort Funston',
      'KEY_EMAIL' => new_resource.key_vars['key_email'] || 'admin@foobar.com',
      'KEY_OU' => new_resource.key_vars['key_org_unit'] || 'OpenVPN Server'
    )
    creates cert_path unless new_resource.force
  end

  execute "gencrl-openvpn-#{new_resource.client_name}" do
    environment(key_environment("#{new_resource.key_vars['key_org'] || 'Fort Funston'} CA"))
    command 'umask 077 && ' \
            "openssl ca -config #{new_resource.easy_rsa_dir}/openssl.cnf " \
            '-gencrl ' \
            '-crlexts crl_ext ' \
            "-md #{new_resource.message_digest} " \
            "-keyfile #{new_resource.key_dir}/ca.key " \
            "-cert #{new_resource.key_dir}/ca.crt " \
            "-out #{new_resource.key_dir}/crl.pem"
    only_if { regenerate_crl? }
  end

  remote_file new_resource.crl_path do
    mode '0644'
    source "file://#{new_resource.key_dir}/crl.pem"
    only_if { ::File.exist?("#{new_resource.key_dir}/crl.pem") }
  end

  cleanup_name = "cleanup-old-bundle-#{new_resource.client_name}"

  template "#{destination_path}/#{client_file_basename}.conf" do
    source 'client.conf.erb'
    cookbook new_resource.cookbook
    variables(
      client_cn: new_resource.client_name,
      compression: compression,
      config: new_resource.config,
      gateway: new_resource.gateway,
      server_verification: new_resource.server_verification
    )
    notifies :delete, "file[#{cleanup_name}]", :immediately
    only_if { new_resource.create_bundle }
  end

  template "#{destination_path}/#{client_file_basename}.ovpn" do
    source new_resource.create_bundle ? 'client.conf.erb' : 'client-inline.conf.erb'
    cookbook new_resource.cookbook
    if new_resource.create_bundle
      variables(
        client_cn: new_resource.client_name,
        compression: compression,
        config: new_resource.config,
        gateway: new_resource.gateway,
        server_verification: new_resource.server_verification
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
            compression: compression,
            config: new_resource.config,
            gateway: new_resource.gateway,
            server_verification: new_resource.server_verification,
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

action_class do
  def regenerate_crl?
    crl = "#{new_resource.key_dir}/crl.pem"
    index = "#{new_resource.key_dir}/index.txt"
    return false unless ::File.exist?(index)
    return false unless ::File.exist?("#{new_resource.key_dir}/ca.key")
    return false unless ::File.exist?("#{new_resource.key_dir}/ca.crt")
    return true unless ::File.exist?(crl)

    ::File.mtime(crl) < ::File.mtime(index)
  end

  def key_environment(common_name)
    {
      'CA_EXPIRE' => (new_resource.key_vars['ca_expire'] || 3650).to_s,
      'KEY_CITY' => new_resource.key_vars['key_city'] || 'San Francisco',
      'KEY_CN' => common_name,
      'KEY_CONFIG' => "#{new_resource.easy_rsa_dir}/openssl.cnf",
      'KEY_COUNTRY' => new_resource.key_vars['key_country'] || 'US',
      'KEY_DIR' => new_resource.key_dir,
      'KEY_EMAIL' => new_resource.key_vars['key_email'] || 'admin@foobar.com',
      'KEY_EXPIRE' => (new_resource.key_vars['key_expire'] || 3650).to_s,
      'KEY_ORG' => new_resource.key_vars['key_org'] || 'Fort Funston',
      'KEY_OU' => new_resource.key_vars['key_org_unit'] || 'OpenVPN Server',
      'KEY_PROVINCE' => new_resource.key_vars['key_province'] || 'CA',
      'KEY_SIZE' => (new_resource.key_vars['key_size'] || 2048).to_s,
    }
  end
end

action :delete do
  client_file_basename = [new_resource.client_prefix, new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || new_resource.key_dir)
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
