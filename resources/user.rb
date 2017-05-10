#
# Cookbook:: openvpn
# Resource:: user
#

property :name, String, name_property: true
property :force, [true, false]

key_dir = node['openvpn']['key_dir']
cert_path = [key_dir, "#{name}.crt"].join("/")
client_file_basename = [node['openvpn']['client_prefix'], name].join('-')
bundle_filename = "#{name}.tar.gz"

action :create do
  execute "generate-openvpn-#{name}" do
    command "./pkitool #{name}"
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

  %w(conf ovpn).each do |ext|
    template "#{key_dir}/#{client_file_basename}.#{ext}" do
      source 'client.conf.erb'
      cookbook node['openvpn']['cookbook_user_conf']
      variables(client_cn: name)
    end
  end

  execute "create-openvpn-tar-#{name}" do
    cwd key_dir
    command <<-EOH
      tar zcf #{bundle_filename} \
        ca.crt #{name}.crt \
        #{name}.key \
        #{client_file_basename}.conf \
        #{client_file_basename}.ovpn
    EOH
    only_if do
      !force && !::File.exist?("#{key_dir}/#{bundle_filename}")
    end
  end
end
