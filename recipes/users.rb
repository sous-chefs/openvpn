#
# Cookbook Name:: openvpn
# Recipe:: users
#
# Copyright 2010-2013, Chef Software, Inc.
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
#

def chef_solo_search_installed?
  klass = ::Search.const_get('Helper')
  return klass.is_a?(Class)
rescue NameError
  return false
end

if Chef::Config[:solo] && !chef_solo_search_installed?
  Chef::Log.warn('This recipe uses search. Chef-Solo does not support search unless '\
    'you install the chef-solo-search cookbook.')
else
  search('users', node['openvpn']['user_query']) do |u|
    execute "generate-openvpn-#{u['id']}" do
      command "./pkitool #{u['id']}"
      cwd '/etc/openvpn/easy-rsa'
      environment(
        'EASY_RSA'     => '/etc/openvpn/easy-rsa',
        'KEY_CONFIG'   => '/etc/openvpn/easy-rsa/openssl.cnf',
        'KEY_DIR'      => node['openvpn']['key_dir'],
        'CA_EXPIRE'    => node['openvpn']['key']['ca_expire'].to_s,
        'KEY_EXPIRE'   => node['openvpn']['key']['expire'].to_s,
        'KEY_SIZE'     => node['openvpn']['key']['size'].to_s,
        'KEY_COUNTRY'  => node['openvpn']['key']['country'],
        'KEY_PROVINCE' => node['openvpn']['key']['province'],
        'KEY_CITY'     => node['openvpn']['key']['city'],
        'KEY_ORG'      => node['openvpn']['key']['org'],
        'KEY_EMAIL'    => node['openvpn']['key']['email']
      )
      not_if { ::File.exist?("#{node['openvpn']['key_dir']}/#{u['id']}.crt") }
    end

    %w(conf ovpn).each do |ext|
      template "#{node['openvpn']['key_dir']}/#{node['openvpn']['client_prefix']}-#{u['id']}.#{ext}" do
        source 'client.conf.erb'
        cookbook node['openvpn']['cookbook_user_conf']
        variables(client_cn: u['id'])
      end
    end

    execute "create-openvpn-tar-#{u['id']}" do
      cwd node['openvpn']['key_dir']
      command <<-EOH
        tar zcf #{u['id']}.tar.gz ca.crt #{u['id']}.crt #{u['id']}.key #{node['openvpn']['client_prefix']}-#{u['id']}.conf #{node['openvpn']['client_prefix']}-#{u['id']}.ovpn
      EOH
      not_if { ::File.exist?("#{node['openvpn']['key_dir']}/#{u['id']}.tar.gz") }
    end
  end
end
