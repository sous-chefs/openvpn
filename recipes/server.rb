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
  group node['root_group']
  recursive true
  mode  '0700'
end

directory [node['openvpn']['fs_prefix'], '/etc/openvpn/easy-rsa'].join do
  owner 'root'
  group node['root_group']
  mode  '0755'
end

%w(openssl.cnf pkitool vars Rakefile).each do |f|
  template [node['openvpn']['fs_prefix'], "/etc/openvpn/easy-rsa/#{f}"].join do
    source "#{f}.erb"
    owner 'root'
    group node['root_group']
    mode  '0755'
  end
end

template [node['openvpn']['fs_prefix'], '/etc/openvpn/server.up.sh'].join do
  source 'server.up.sh.erb'
  owner 'root'
  group node['root_group']
  mode  '0755'
  notifies :restart, 'service[openvpn]'
end

directory [node['openvpn']['fs_prefix'], '/etc/openvpn/server.up.d'].join do
  owner 'root'
  group node['root_group']
  mode  '0755'
end

template "#{key_dir}/openssl.cnf" do
  source 'openssl.cnf.erb'
  owner 'root'
  group node['root_group']
  mode  '0644'
end

file "#{key_dir}/index.txt" do
  owner 'root'
  group node['root_group']
  mode  '0600'
  action :create
end

file "#{key_dir}/serial" do
  content '01'
  action :create_if_missing
end

require 'openssl'

file node['openvpn']['config']['dh'] do
  content lazy { OpenSSL::PKey::DH.new(key_size).to_s }
  owner   'root'
  group   node['root_group']
  mode    '0600'
  action :create_if_missing
end

execute 'openvpn-initca' do
  environment(
    'KEY_CN' => "#{node['openvpn']['key']['org']} CA",
    'KEY_EMAIL' => "#{node['openvpn']['key']['email']}",
    'KEY_COUNTRY' => "#{node['openvpn']['key']['country']}",
    'KEY_CITY' => "#{node['openvpn']['key']['city']}",
    'KEY_PROVINCE' => "#{node['openvpn']['key']['province']}",
    'KEY_DIR' => '/etc/openvpn/keys',
    'KEY_SIZE' => "#{node['openvpn']['key']['size']}",
    'KEY_ORG' => "#{node['openvpn']['key']['org']}",
    'KEY_OU' => 'OpenVPN Server'
  )
  command 'umask 077 && ' \
          "openssl req -batch -days #{node['openvpn']['key']['ca_expire']} " \
          "-nodes -new -newkey rsa:#{key_size} -#{message_digest} -x509 " \
          "-keyout #{node['openvpn']['signing_ca_key']} " \
          "-out #{node['openvpn']['signing_ca_cert']} " \
          "-config #{key_dir}/openssl.cnf"
  not_if { ::File.exist?(node['openvpn']['signing_ca_cert']) }
end

execute 'openvpn-server-key' do
  environment(
    'KEY_CN' => 'server',
    'KEY_EMAIL' => "#{node['openvpn']['key']['email']}",
    'KEY_COUNTRY' => "#{node['openvpn']['key']['country']}",
    'KEY_CITY' => "#{node['openvpn']['key']['city']}",
    'KEY_PROVINCE' => "#{node['openvpn']['key']['province']}",
    'KEY_DIR' => '/etc/openvpn/keys',
    'KEY_SIZE' => "#{node['openvpn']['key']['size']}",
    'KEY_ORG' => "#{node['openvpn']['key']['org']}",
    'KEY_OU' => 'OpenVPN Server'
  )
  command 'umask 077 && ' \
          "openssl req -batch -days #{node['openvpn']['key']['expire']} " \
          "-nodes -new -newkey rsa:#{key_size} -keyout #{key_dir}/server.key " \
          "-out #{key_dir}/server.csr -extensions server " \
          "-config #{key_dir}/openssl.cnf && " \
          "openssl ca -batch -days #{node['openvpn']['key']['ca_expire']} " \
          "-out #{key_dir}/server.crt -in #{key_dir}/server.csr " \
          "-extensions server -md #{message_digest} -config #{key_dir}/openssl.cnf"
  not_if { ::File.exist?("#{key_dir}/server.crt") }
end

[node['openvpn']['signing_ca_key'], "#{key_dir}/server.key"].each do |key|
  file key do
    # Just fixes permissions.
    action :create
    owner 'root'
    group node['root_group']
    mode '0600'
  end
end

execute 'gencrl' do
  environment(
    'KEY_CN' => "#{node['openvpn']['key']['org']} CA",
    'KEY_EMAIL' => "#{node['openvpn']['key']['email']}",
    'KEY_COUNTRY' => "#{node['openvpn']['key']['country']}",
    'KEY_CITY' => "#{node['openvpn']['key']['city']}",
    'KEY_PROVINCE' => "#{node['openvpn']['key']['province']}",
    'KEY_DIR' => '/etc/openvpn/keys',
    'KEY_SIZE' => "#{node['openvpn']['key']['size']}",
    'KEY_ORG' => "#{node['openvpn']['key']['org']}",
    'KEY_OU' => 'OpenVPN Server'
  )
  command 'umask 077 && ' \
          "openssl ca -config #{[node['openvpn']['fs_prefix'], '/etc/openvpn/easy-rsa/openssl.cnf'].join} " \
          '-gencrl ' \
          '-crlexts crl_ext ' \
          "-md #{node['openvpn']['key']['message_digest']} " \
          "-keyfile #{key_dir}/ca.key " \
          "-cert #{key_dir}/ca.crt " \
          "-out #{key_dir}/crl.pem"
  only_if do
    crl = "#{key_dir}/crl.pem"
    generate = false
    if !::File.exist?(crl)
      generate = true
    else
      crl_mtime = ::File.mtime(crl)
      index_mtime = ::File.mtime("#{key_dir}/index.txt")
      renew_after = ::Date.today - node['openvpn']['key']['crl_expire'] / 2
      generate = true if crl_mtime < renew_after.to_time
      generate = true if crl_mtime < index_mtime
    end
    generate
  end
  action :run
  notifies :create, "remote_file[#{[node['openvpn']['fs_prefix'], '/etc/openvpn/crl.pem'].join}]"
end

# Make a world readable copy of the CRL
remote_file [node['openvpn']['fs_prefix'], '/etc/openvpn/crl.pem'].join do
  mode   '644'
  source "file://#{key_dir}/crl.pem"
end

# the FreeBSD service expects openvpn.conf
conf_name = if platform?('freebsd')
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
