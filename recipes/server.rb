# TODO: update for use with node['openvpn']['config']
# routes = node['openvpn']['config']['routes']
# routes << node['openvpn']['push'] if node['openvpn'].attribute?('push')
# node.default['openvpn']['config']['routes'] = routes.flatten

# in the case the key size is provided as string, no integer support in metadata (CHEF-4075)
node.override['openvpn']['key']['size'] = node['openvpn']['key']['size'].to_i

key_dir  = node['openvpn']['key_dir']
key_size = node['openvpn']['key']['size']

include_recipe 'yum-epel' if platform_family?('rhel')

directory key_dir do
  owner 'root'
  group 'root'
  mode  '0700'
end

directory '/etc/openvpn/easy-rsa' do
  owner 'root'
  group 'root'
  mode  '0755'
end

%w(openssl.cnf pkitool vars Rakefile).each do |f|
  template "/etc/openvpn/easy-rsa/#{f}" do
    source "#{f}.erb"
    owner 'root'
    group 'root'
    mode  '0755'
  end
end

template '/etc/openvpn/server.up.sh' do
  source 'server.up.sh.erb'
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :restart, 'service[openvpn]'
end

directory '/etc/openvpn/server.up.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template "#{key_dir}/openssl.cnf" do
  source 'openssl.cnf.erb'
  owner 'root'
  group 'root'
  mode  '0644'
end

file "#{key_dir}/index.txt" do
  owner 'root'
  group 'root'
  mode  '0600'
  action :create
end

file "#{key_dir}/serial" do
  content '01'
  not_if { ::File.exist?("#{key_dir}/serial") }
end

# Use unless instead of not_if otherwise OpenSSL::PKey::DH runs every time.
unless ::File.exist?("#{key_dir}/dh#{key_size}.pem")
  require 'openssl'
  file "#{key_dir}/dh#{key_size}.pem" do
    content OpenSSL::PKey::DH.new(key_size).to_s
    owner 'root'
    group 'root'
    mode  '0600'
  end
end

bash 'openvpn-initca' do
  environment('KEY_CN' => "#{node['openvpn']['key']['org']} CA")
  code <<-EOF
    openssl req -batch -days #{node['openvpn']['key']['ca_expire']} \
      -nodes -new -newkey rsa:#{key_size} -sha1 -x509 \
      -keyout #{node['openvpn']['signing_ca_key']} \
      -out #{node['openvpn']['signing_ca_cert']} \
      -config #{key_dir}/openssl.cnf
  EOF
  not_if { ::File.exist?(node['openvpn']['signing_ca_cert']) }
end

bash 'openvpn-server-key' do
  environment('KEY_CN' => 'server')
  code <<-EOF
    openssl req -batch -days #{node['openvpn']['key']['expire']} \
      -nodes -new -newkey rsa:#{key_size} -keyout #{key_dir}/server.key \
      -out #{key_dir}/server.csr -extensions server \
      -config #{key_dir}/openssl.cnf && \
    openssl ca -batch -days #{node['openvpn']['key']['ca_expire']} \
      -out #{key_dir}/server.crt -in #{key_dir}/server.csr \
      -extensions server -md sha1 -config #{key_dir}/openssl.cnf
  EOF
  not_if { ::File.exist?("#{key_dir}/server.crt") }
end

openvpn_conf 'server' do
  notifies :restart, 'service[openvpn]'
  only_if { node['openvpn']['configure_default_server'] }
  action :create
end
