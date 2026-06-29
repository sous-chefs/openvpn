# frozen_string_literal: true

require 'openssl'

provides :openvpn_server
unified_mode true

property :config_name, String, name_property: true
property :package_name, String, default: 'openvpn'
property :install_epel, [true, false], default: true
property :key_dir, String, default: '/etc/openvpn/keys'
property :easy_rsa_dir, String, default: '/etc/openvpn/easy-rsa'
property :config_path, [String, nil]
property :up_script_path, String, default: '/etc/openvpn/server.up.sh'
property :up_script_dir, String, default: '/etc/openvpn/server.up.d'
property :crl_path, String, default: '/etc/openvpn/crl.pem'
property :subnet, String, default: '10.8.0.0'
property :netmask, String, default: '255.255.0.0'
property :config, [Hash, nil]
property :push_routes, Array, default: []
property :push_options, Hash, default: {}
property :client_cn, String, default: 'client'
property :key_size, [Integer, String], default: 2048
property :ca_expire, [Integer, String], default: 3650
property :key_expire, [Integer, String], default: 3650
property :crl_expire, [Integer, String], default: 30
property :key_country, String, default: 'US'
property :key_province, String, default: 'CA'
property :key_city, String, default: 'San Francisco'
property :key_org, String, default: 'Fort Funston'
property :key_email, String, default: 'admin@foobar.com'
property :message_digest, String, default: 'sha256'
property :configure, [true, false], default: true
property :enable_ip_forwarding, [true, false], default: true
property :install_bridge_utils, [true, false], default: false
property :cookbook, String, default: 'openvpn'

action :create do
  openvpn_install 'default' do
    package_name new_resource.package_name
    install_epel new_resource.install_epel
    install_tar true
    install_bash true
    action :install
  end

  package 'bridge-utils' do
    only_if { new_resource.install_bridge_utils }
  end

  sysctl 'net.ipv4.conf.all.forwarding' do
    value 1
    only_if { new_resource.enable_ip_forwarding }
  end

  sysctl 'net.ipv6.conf.all.forwarding' do
    value 1
    only_if { new_resource.enable_ip_forwarding && ::Dir.exist?('/proc/sys/net/ipv6') }
  end

  [new_resource.key_dir, new_resource.easy_rsa_dir, new_resource.up_script_dir].each do |dir|
    directory dir do
      owner 'root'
      group node['root_group']
      recursive true
      mode dir == new_resource.key_dir ? '0700' : '0755'
    end
  end

  %w(openssl.cnf pkitool vars Rakefile).each do |template_name|
    template "#{new_resource.easy_rsa_dir}/#{template_name}" do
      cookbook new_resource.cookbook
      source "#{template_name}.erb"
      owner 'root'
      group node['root_group']
      mode '0755'
      variables(template_variables)
    end
  end

  template new_resource.up_script_path do
    cookbook new_resource.cookbook
    source 'server.up.sh.erb'
    owner 'root'
    group node['root_group']
    mode '0755'
    variables(template_variables)
    notifies :restart, "openvpn_service[#{new_resource.config_name}]"
  end

  template "#{new_resource.key_dir}/openssl.cnf" do
    cookbook new_resource.cookbook
    source 'openssl.cnf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(template_variables)
  end

  file "#{new_resource.key_dir}/index.txt" do
    owner 'root'
    group node['root_group']
    mode '0600'
    action :create
  end

  file "#{new_resource.key_dir}/serial" do
    content '01'
    action :create_if_missing
  end

  file server_config.fetch('dh') do
    content lazy { OpenSSL::PKey::DH.new(new_resource.key_size.to_i).to_s }
    owner 'root'
    group node['root_group']
    mode '0600'
    action :create_if_missing
  end

  execute 'openvpn-initca' do
    environment(key_environment("#{new_resource.key_org} CA"))
    command 'umask 077 && ' \
            "openssl req -batch -days #{new_resource.ca_expire} " \
            "-nodes -new -newkey rsa:#{new_resource.key_size} -#{new_resource.message_digest} -x509 " \
            "-keyout #{signing_ca_key} " \
            "-out #{signing_ca_cert} " \
            "-config #{new_resource.key_dir}/openssl.cnf"
    not_if { ::File.exist?(signing_ca_cert) }
  end

  execute 'openvpn-server-key' do
    environment(key_environment('server'))
    command 'umask 077 && ' \
            "openssl req -batch -days #{new_resource.key_expire} " \
            "-nodes -new -newkey rsa:#{new_resource.key_size} -keyout #{new_resource.key_dir}/server.key " \
            "-out #{new_resource.key_dir}/server.csr -extensions server " \
            "-config #{new_resource.key_dir}/openssl.cnf && " \
            "openssl ca -batch -days #{new_resource.ca_expire} " \
            "-out #{new_resource.key_dir}/server.crt -in #{new_resource.key_dir}/server.csr " \
            "-extensions server -md #{new_resource.message_digest} -config #{new_resource.key_dir}/openssl.cnf"
    not_if { ::File.exist?("#{new_resource.key_dir}/server.crt") }
  end

  [signing_ca_key, "#{new_resource.key_dir}/server.key"].each do |key|
    file key do
      action :create
      owner 'root'
      group node['root_group']
      mode '0600'
      only_if { ::File.exist?(key) }
    end
  end

  execute 'gencrl' do
    environment(key_environment("#{new_resource.key_org} CA"))
    command 'umask 077 && ' \
            "openssl ca -config #{new_resource.easy_rsa_dir}/openssl.cnf " \
            '-gencrl ' \
            '-crlexts crl_ext ' \
            "-md #{new_resource.message_digest} " \
            "-keyfile #{signing_ca_key} " \
            "-cert #{signing_ca_cert} " \
            "-out #{new_resource.key_dir}/crl.pem"
    only_if { generate_crl? }
    action :run
    notifies :create, "remote_file[#{new_resource.crl_path}]"
  end

  remote_file new_resource.crl_path do
    mode '0644'
    source "file://#{new_resource.key_dir}/crl.pem"
  end

  openvpn_conf new_resource.config_name do
    config_path resolved_config_path
    cookbook new_resource.cookbook
    config server_config
    push_routes new_resource.push_routes
    push_options new_resource.push_options
    client_cn new_resource.client_cn
    notifies :restart, "openvpn_service[#{new_resource.config_name}]"
    only_if { new_resource.configure }
  end

  openvpn_service new_resource.config_name do
    config_path resolved_config_path
    service_type 'server'
    action [:enable, :start]
  end
end

action :delete do
  openvpn_service new_resource.config_name do
    action :delete
  end

  openvpn_conf new_resource.config_name do
    config_path resolved_config_path
    action :delete
  end

  [new_resource.crl_path, new_resource.up_script_path].each do |path|
    file path do
      action :delete
    end
  end
end

action_class do
  def resolved_config_path
    return new_resource.config_path if new_resource.config_path

    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora')
      "/etc/openvpn/#{new_resource.config_name}/#{new_resource.config_name}.conf"
    else
      "/etc/openvpn/#{new_resource.config_name}.conf"
    end
  end

  def signing_ca_key
    "#{new_resource.key_dir}/ca.key"
  end

  def signing_ca_cert
    "#{new_resource.key_dir}/ca.crt"
  end

  def server_config
    new_resource.config || default_server_config
  end

  def default_server_config
    {
      'ca' => signing_ca_cert,
      'cert' => "#{new_resource.key_dir}/server.crt",
      'crl-verify' => new_resource.crl_path,
      'dev' => 'tun0',
      'dh' => "#{new_resource.key_dir}/dh#{new_resource.key_size}.pem",
      'group' => platform_family?('debian') ? 'nogroup' : 'nobody',
      'keepalive' => '10 120',
      'key' => "#{new_resource.key_dir}/server.key",
      'log' => '/var/log/openvpn.log',
      'persist-key' => '',
      'persist-tun' => '',
      'port' => '1194',
      'proto' => 'udp',
      'script-security' => 2,
      'server' => "#{new_resource.subnet} #{new_resource.netmask}",
      'up' => new_resource.up_script_path,
      'user' => 'nobody',
    }
  end

  def key_environment(common_name)
    {
      'CA_EXPIRE' => new_resource.ca_expire.to_s,
      'KEY_CITY' => new_resource.key_city,
      'KEY_CN' => common_name,
      'KEY_CONFIG' => "#{new_resource.easy_rsa_dir}/openssl.cnf",
      'KEY_COUNTRY' => new_resource.key_country,
      'KEY_DIR' => new_resource.key_dir,
      'KEY_EMAIL' => new_resource.key_email,
      'KEY_EXPIRE' => new_resource.key_expire.to_s,
      'KEY_ORG' => new_resource.key_org,
      'KEY_OU' => 'OpenVPN Server',
      'KEY_PROVINCE' => new_resource.key_province,
      'KEY_SIZE' => new_resource.key_size.to_s,
    }
  end

  def generate_crl?
    crl = "#{new_resource.key_dir}/crl.pem"
    return true unless ::File.exist?(crl)
    return true if ::File.mtime(crl) < ::File.mtime("#{new_resource.key_dir}/index.txt")

    ::File.mtime(crl) < (::Date.today - new_resource.crl_expire.to_i / 2).to_time
  end

  def template_variables
    {
      ca_expire: new_resource.ca_expire,
      crl_expire: new_resource.crl_expire,
      key_city: new_resource.key_city,
      key_country: new_resource.key_country,
      key_dir: new_resource.key_dir,
      key_email: new_resource.key_email,
      key_expire: new_resource.key_expire,
      key_org: new_resource.key_org,
      key_province: new_resource.key_province,
      key_size: new_resource.key_size,
      message_digest: new_resource.message_digest,
      netmask: new_resource.netmask,
      server_verification: nil,
      signing_ca_cert: signing_ca_cert,
      signing_ca_key: signing_ca_key,
      subnet: new_resource.subnet,
      vpn_config: server_config,
    }
  end
end
