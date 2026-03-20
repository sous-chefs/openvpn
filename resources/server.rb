# frozen_string_literal: true

provides :openvpn_server
unified_mode true

default_action :create

use '_partial/_pki'

property :crl_expire, Integer, default: 30
property :message_digest, String, default: 'sha256'

# Server properties
property :subnet, String, default: '10.8.0.0'
property :netmask, String, default: '255.255.0.0'
property :server_up_script, [true, false], default: true

action :create do
  ca_key = "#{new_resource.key_dir}/ca.key"
  ca_cert = "#{new_resource.key_dir}/ca.crt"
  key_size = new_resource.key_size
  message_digest = new_resource.message_digest
  key_dir = new_resource.key_dir

  directory key_dir do
    owner 'root'
    group 'root'
    recursive true
    mode '0700'
  end

  directory new_resource.easy_rsa_dir do
    owner 'root'
    group 'root'
    mode '0755'
  end

  %w(openssl.cnf pkitool vars Rakefile).each do |f|
    template "#{new_resource.easy_rsa_dir}/#{f}" do
      source "#{f}.erb"
      cookbook 'openvpn'
      owner 'root'
      group 'root'
      mode '0755'
      variables(
        key_dir: key_dir,
        key_size: key_size,
        ca_expire: new_resource.ca_expire,
        key_expire: new_resource.key_expire,
        crl_expire: new_resource.crl_expire,
        key_country: new_resource.key_country,
        key_province: new_resource.key_province,
        key_city: new_resource.key_city,
        key_org: new_resource.key_org,
        key_email: new_resource.key_email,
        signing_ca_cert: ca_cert,
        signing_ca_key: ca_key
      )
    end
  end

  if new_resource.server_up_script
    template '/etc/openvpn/server.up.sh' do
      source 'server.up.sh.erb'
      cookbook 'openvpn'
      owner 'root'
      group 'root'
      mode '0755'
      variables(
        subnet: new_resource.subnet,
        netmask: new_resource.netmask
      )
    end

    directory '/etc/openvpn/server.up.d' do
      owner 'root'
      group 'root'
      mode '0755'
    end
  end

  template "#{key_dir}/openssl.cnf" do
    source 'openssl.cnf.erb'
    cookbook 'openvpn'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      key_dir: key_dir,
      key_size: key_size,
      ca_expire: new_resource.ca_expire,
      crl_expire: new_resource.crl_expire,
      signing_ca_cert: ca_cert,
      signing_ca_key: ca_key
    )
  end

  file "#{key_dir}/index.txt" do
    owner 'root'
    group 'root'
    mode '0600'
    action :create
  end

  file "#{key_dir}/serial" do
    content '01'
    action :create_if_missing
  end

  pki_env = {
    'KEY_CN' => "#{new_resource.key_org} CA",
    'KEY_EMAIL' => new_resource.key_email,
    'KEY_COUNTRY' => new_resource.key_country,
    'KEY_CITY' => new_resource.key_city,
    'KEY_PROVINCE' => new_resource.key_province,
    'KEY_DIR' => key_dir,
    'KEY_SIZE' => key_size.to_s,
    'KEY_ORG' => new_resource.key_org,
    'KEY_OU' => 'OpenVPN Server',
  }

  file "#{key_dir}/dh#{key_size}.pem" do
    content lazy {
      require 'openssl'
      OpenSSL::PKey::DH.new(key_size).to_s
    }
    owner 'root'
    group 'root'
    mode '0600'
    action :create_if_missing
  end

  execute 'openvpn-initca' do
    environment pki_env
    command 'umask 077 && ' \
            "openssl req -batch -days #{new_resource.ca_expire} " \
            "-nodes -new -newkey rsa:#{key_size} -#{message_digest} -x509 " \
            "-keyout #{ca_key} " \
            "-out #{ca_cert} " \
            "-config #{key_dir}/openssl.cnf"
    not_if { ::File.exist?(ca_cert) }
  end

  execute 'openvpn-server-key' do
    environment pki_env.merge('KEY_CN' => 'server')
    command 'umask 077 && ' \
            "openssl req -batch -days #{new_resource.key_expire} " \
            "-nodes -new -newkey rsa:#{key_size} -keyout #{key_dir}/server.key " \
            "-out #{key_dir}/server.csr -extensions server " \
            "-config #{key_dir}/openssl.cnf && " \
            "openssl ca -batch -days #{new_resource.ca_expire} " \
            "-out #{key_dir}/server.crt -in #{key_dir}/server.csr " \
            "-extensions server -md #{message_digest} -config #{key_dir}/openssl.cnf"
    not_if { ::File.exist?("#{key_dir}/server.crt") }
  end

  [ca_key, "#{key_dir}/server.key"].each do |key|
    file key do
      action :create
      owner 'root'
      group 'root'
      mode '0600'
    end
  end

  execute 'gencrl' do
    environment pki_env
    command 'umask 077 && ' \
            "openssl ca -config #{new_resource.easy_rsa_dir}/openssl.cnf " \
            '-gencrl ' \
            '-crlexts crl_ext ' \
            "-md #{message_digest} " \
            "-keyfile #{key_dir}/ca.key " \
            "-cert #{key_dir}/ca.crt " \
            "-out #{key_dir}/crl.pem"
    only_if do
      crl = "#{key_dir}/crl.pem"
      if !::File.exist?(crl)
        true
      else
        crl_mtime = ::File.mtime(crl)
        index_mtime = ::File.mtime("#{key_dir}/index.txt")
        renew_after = ::Date.today - new_resource.crl_expire / 2
        crl_mtime < renew_after.to_time || crl_mtime < index_mtime
      end
    end
    action :run
    notifies :create, 'remote_file[/etc/openvpn/crl.pem]'
  end

  remote_file '/etc/openvpn/crl.pem' do
    mode '0644'
    source "file://#{key_dir}/crl.pem"
  end
end
