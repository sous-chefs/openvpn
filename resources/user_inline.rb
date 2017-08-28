#
# Cookbook:: openvpn
# Resource:: user_bundle
#

property :client_name, String, name_property: true
property :destination, String
property :additional_vars, Hash

action :create do
  key_dir = node['openvpn']['key_dir']

  ca_cert_path = ::File.join(key_dir, "ca.crt")
  cert_path = ::File.join(key_dir, "#{client_name}.crt")
  key_path = ::File.join(key_dir, "#{client_name}.key")


  filename = "#{client_name}.ovpn"
  full_path = ::File.expand_path(::File.join(key_dir, filename))
  destination_file = ::File.expand_path(destination || full_path)

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

  template destination_file do
    source "client-inline.conf.erb"
    cookbook node['openvpn']['cookbook_user_inline_conf']

    sensitive true
    variables(
      lazy do
        {
          client_cn: client_name,

          ca: IO.read(ca_cert_path),
          cert: IO.read(cert_path),
          key: IO.read(key_path)
        }.merge(additional_vars){|key, oldval, newval| oldval}
      end
    )
  end
end

action :delete do
  key_dir = node['openvpn']['key_dir']

  filename = "#{client_name}.ovpn"
  full_path = ::File.expand_path(::File.join(key_dir, filename))
  destination_file = ::File.expand_path(destination || full_path)

  file destination_file do
    action :delete
  end
end
