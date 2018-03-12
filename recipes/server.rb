#
# Cookbook:: openvpn
# Recipe:: server
#
# Copyright:: 2009-2018, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'openvpn::enable_ip_forwarding'
include_recipe 'openvpn::install_bridge_utils' if node['openvpn']['type'] == 'bridge'
include_recipe 'openvpn::install'

# this recipe currently uses the bash resource, ensure it is installed
p = package 'bash' do
  action :nothing
end
p.run_action(:install)

# in the case the key size is provided as string, no integer support in metadata (CHEF-4075)
node.override['openvpn']['key']['size'] = node['openvpn']['key']['size'].to_i

key_dir  = node['openvpn']['key_dir']
key_size = node['openvpn']['key']['size']
message_digest = node['openvpn']['key']['message_digest']

directory key_dir do
  owner 'root'
  group node['openvpn']['root_group']
  recursive true
  mode  '0700'
end

directory [node['openvpn']['fs_prefix'], '/etc/openvpn/easy-rsa'].join do
  owner 'root'
  group node['openvpn']['root_group']
  mode  '0755'
end

%w(openssl.cnf pkitool vars Rakefile).each do |f|
  template [node['openvpn']['fs_prefix'], "/etc/openvpn/easy-rsa/#{f}"].join do
    source "#{f}.erb"
    owner 'root'
    group node['openvpn']['root_group']
    mode  '0755'
  end
end

template [node['openvpn']['fs_prefix'], '/etc/openvpn/server.up.sh'].join do
  source 'server.up.sh.erb'
  owner 'root'
  group node['openvpn']['root_group']
  mode  '0755'
  notifies :restart, 'service[openvpn]'
end

directory [node['openvpn']['fs_prefix'], '/etc/openvpn/server.up.d'].join do
  owner 'root'
  group node['openvpn']['root_group']
  mode  '0755'
end

template "#{key_dir}/openssl.cnf" do
  source 'openssl.cnf.erb'
  owner 'root'
  group node['openvpn']['root_group']
  mode  '0644'
end

file "#{key_dir}/index.txt" do
  owner 'root'
  group node['openvpn']['root_group']
  mode  '0600'
  action :create
end

file "#{key_dir}/serial" do
  content '01'
  not_if { ::File.exist?("#{key_dir}/serial") }
end

require 'openssl'

file node['openvpn']['config']['dh'] do
  content lazy { OpenSSL::PKey::DH.new(key_size).to_s }
  owner   'root'
  group   node['openvpn']['root_group']
  mode    '0600'
  not_if  { ::File.exist?(node['openvpn']['config']['dh']) }
end

bash 'openvpn-initca' do
  environment('KEY_CN' => "#{node['openvpn']['key']['org']} CA")
  code <<-EOF
    openssl req -batch -days #{node['openvpn']['key']['ca_expire']} \
      -nodes -new -newkey rsa:#{key_size} -#{message_digest} -x509 \
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
      -extensions server -md #{message_digest} -config #{key_dir}/openssl.cnf
  EOF
  not_if { ::File.exist?("#{key_dir}/server.crt") }
end

[node['openvpn']['signing_ca_key'], "#{key_dir}/server.key"].each do |key|
  file key do
    # Just fixes permissions.
    action :create
    owner 'root'
    group node['openvpn']['root_group']
    mode '0600'
  end
end

execute 'gencrl' do
  environment('KEY_CN' => "#{node['openvpn']['key']['org']} CA")
  command "openssl ca -config #{[node['openvpn']['fs_prefix'], '/etc/openvpn/easy-rsa/openssl.cnf'].join} -gencrl " \
          "-keyfile #{node['openvpn']['key_dir']}/server.key " \
          "-cert #{node['openvpn']['key_dir']}/server.crt " \
          "-out #{node['openvpn']['key_dir']}/crl.pem"
  creates "#{node['openvpn']['key_dir']}/crl.pem"
  action  :run
end

# Make a world readable copy of the CRL
remote_file [node['openvpn']['fs_prefix'], '/etc/openvpn/crl.pem'].join do
  mode   '644'
  source "file://#{node['openvpn']['key_dir']}/crl.pem"
end

# the FreeBSD service expects openvpn.conf
conf_name = if node['platform'] == 'freebsd'
              'openvpn'
            else
              'server'
            end

openvpn_conf conf_name do
  notifies :restart, 'service[openvpn]'
  only_if { node['openvpn']['configure_default_server'] }
  action :create
end

include_recipe 'openvpn::service'
