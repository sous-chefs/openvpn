#
# Cookbook:: openvpn
# Resource:: user
#

property :client_name, String, name_property: true
property :create_bundle, [true, false], default: true
property :force, [true, false]
property :destination, String
property :additional_vars, Hash, default: {}

# TODO: this action will not recreate if the client configuration data has
#       changed. Requires manual intervention.

action :create do
  # Setup some variables
  key_dir = node['openvpn']['key_dir']
  cert_path = ::File.join(key_dir, "#{new_resource.client_name}.crt")
  ca_cert_path = ::File.join(key_dir, 'ca.crt')
  key_path = ::File.join(key_dir, "#{new_resource.client_name}.key")
  client_file_basename = [node['openvpn']['client_prefix'], new_resource.client_name].join('-')
  destination_path = ::File.expand_path(new_resource.destination || key_dir)
  bundle_filename = "#{new_resource.client_name}.tar.gz"
  bundle_full_path = ::File.expand_path(::File.join(destination_path, bundle_filename))
  compression = if node['openvpn']['config']['compress']
                  node['openvpn']['config']['compress']
                elsif node['openvpn']['config']['comp-lzo']
                  'lzo'
                end

  execute "generate-openvpn-#{new_resource.client_name}" do
    command "./pkitool #{new_resource.client_name}"
    cwd '/etc/openvpn/easy-rsa'
    environment(
      'EASY_RSA' => '/etc/openvpn/easy-rsa',
      'KEY_CONFIG' => '/etc/openvpn/easy-rsa/openssl.cnf',
      'KEY_DIR' => key_dir,
      'CA_EXPIRE' => node['openvpn']['key']['ca_expire'].to_s,
      'KEY_EXPIRE' => node['openvpn']['key']['expire'].to_s,
      'KEY_SIZE' => node['openvpn']['key']['size'].to_s,
      'KEY_COUNTRY' => node['openvpn']['key']['country'],
      'KEY_PROVINCE' => node['openvpn']['key']['province'],
      'KEY_CITY' => node['openvpn']['key']['city'],
      'KEY_ORG' => node['openvpn']['key']['org'],
      'KEY_EMAIL' => node['openvpn']['key']['email']
    )
    creates cert_path unless new_resource.force
  end

  cleanup_name = "cleanup-old-bundle-#{new_resource.client_name}"

  template "#{destination_path}/#{client_file_basename}.conf" do
    source 'client.conf.erb'
    cookbook lazy { node['openvpn']['cookbook_user_conf'] }
    variables(client_cn: new_resource.client_name)
    notifies :delete, "file[#{cleanup_name}]", :immediately
    only_if { new_resource.create_bundle }
  end

  template "#{destination_path}/#{client_file_basename}.ovpn" do
    source new_resource.create_bundle ? 'client.conf.erb' : 'client-inline.conf.erb'
    cookbook lazy { node['openvpn']['cookbook_user_conf'] }
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
            compression: compression,
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
    command "tar zcf #{bundle_filename} #{filelist}"
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
