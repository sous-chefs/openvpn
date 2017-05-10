#
# Cookbook:: openvpn
# Resource:: user
#

property :client_name, String, name_property: true
property :force, [true, false]
property :destination, String

# TODO: this action will not recreate if the client configuration data has
#       changed. Requires manual intervention.
action :create do
  key_dir = node['openvpn']['key_dir']
  cert_path = ::File.join(key_dir, "#{client_name}.crt")
  client_file_basename = [node['openvpn']['client_prefix'], name].join('-')
  bundle_filename = "#{client_name}.tar.gz"

  bundle_full_path = ::File.expand_path("#{key_dir}/bundle_filename")
  destination_file = File.expand_path(destination || bundle_full_path)

  execute "generate-openvpn-#{client_name}" do
    command "./pkitool #{client_name}"
    cwd '/etc/openvpn/easy-rsa'
    environment(
      'EASY_RSA'     => '/etc/openvpn/easy-rsa',
      'KEY_CONFIG'   => '/etc/openvpn/easy-rsa/openssl.cnf',
      'KEY_DIR'      => key_dir,
      'CA_EXPIRE'    => node['openvpn']['key']['ca_expire'].to_s,
      'KEY_EXPIRE'   => node['openvpn']['key']['expire'].to_s,
      'KEY_SIZE'     => node['openvpn']['key']['size'].to_s,
      'KEY_COUNTRY'  => node['openvpn']['key']['country'],
      'KEY_PROVINCE' => node['openvpn']['key']['province'],
      'KEY_CITY'     => node['openvpn']['key']['city'],
      'KEY_ORG'      => node['openvpn']['key']['org'],
      'KEY_EMAIL'    => node['openvpn']['key']['email']
    )
    not_if { ::File.exist?(cert_path) }
  end

  cleanup_name = "cleanup-old-bundle-#{client_name}"

  %w(conf ovpn).each do |ext|
    filename = "#{key_dir}/#{client_file_basename}.#{ext}"
    template filename do
      source 'client.conf.erb'
      cookbook node['openvpn']['cookbook_user_conf']
      variables(client_cn: name)

      notifies :delete, "file[#{cleanup_name}]", :immediately
    end
  end

  file cleanup_name do
    action :nothing

    path destination_file
  end

  execute "create-openvpn-tar-#{client_name}" do
    cwd key_dir
    command <<-EOH
      tar zcf #{bundle_filename} \
        ca.crt #{client_name}.crt \
        #{client_name}.key \
        #{client_file_basename}.conf \
        #{client_file_basename}.ovpn
    EOH

    not_if { !force && ::File.exist?(destination_file) }
  end



  execute "move-bundle-to-destination-#{client_name}" do
    command <<-EOH
      mv #{bundle_filename_real} #{destination_file}
    EOH

    not_if do
      bundle_full_path != destination_file ||
        (!force && ::File.exist?(destination_file))
    end
  end
end
