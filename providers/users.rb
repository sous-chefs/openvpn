#
# Cookbook Name:: openvpn
# Provider:: users
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

use_inline_resources if defined?(use_inline_resources)

action :create do
  if Chef::Config[:solo] && !OpenVPN::Helper.chef_solo_search_installed?
    Chef::Log.warn('This recipe uses search. Chef-Solo does not support search unless '\
      'you install the chef-solo-search cookbook.')
  else
    search(new_resource.data_bag, node['openvpn']['user_query']) do |u|
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
        template "#{node['openvpn']['key_dir']}/" \
                 "#{node['openvpn']['client_prefix']}-#{u['id']}.#{ext}" do
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
end

action :remove do
  if Chef::Config[:solo] && !OpenVPN::Helper.chef_solo_search_installed?
    Chef::Log.warn('This recipe uses search. Chef-Solo does not support search unless '\
      'you install the chef-solo-search cookbook.')
  else
    search(new_resource.data_bag, node['openvpn']['remove_user_query']) do |u|
      execute "revoke-openvpn-#{u['id']}" do
        command '. /etc/openvpn/easy-rsa/vars && openssl ca -revoke' \
          " #{node['openvpn']['key_dir']}/#{u['id']}.crt" \
          " -config #{node['openvpn']['key_dir']}/openssl.cnf"
        cwd node['openvpn']['key_dir']
        environment(
          'KEY_CN'        => '',
          'KEY_OU'        => '',
          'KEY_NAME'      => '',
          'KEY_ALTNAMES'  => ''
        )
        only_if do
          ::File.exist?("#{node['openvpn']['key_dir']}/#{u['id']}.crt") &&
            OpenVPN::Helper.cert_valid?(node['openvpn']['key_dir'], "#{u['id']}.crt")
        end
        notifies :run, 'execute[gencrl]', :immediately
      end

      ruby_block "check-#{u['id']}-revocation" do
        block do
          if OpenVPN::Helper.cert_valid?(node['openvpn']['key_dir'], "#{u['id']}.crt")
            Chef::Log.fatal("Failed to revoke certificate for #{u['id']}")
            raise "#{node['openvpn']['key_dir']}/#{u['id']}.crt is still valid"
          end
        end
        only_if { ::File.exist?("#{node['openvpn']['key_dir']}/#{u['id']}.crt") }
      end

      %w(tar.gz crt key csr).each do |ext|
        file "#{node['openvpn']['key_dir']}/#{u['id']}.#{ext}" do
          action :delete
        end
      end
      %w(conf ovpn).each do |ext|
        file "#{node['openvpn']['key_dir']}/" \
             "#{node['openvpn']['client_prefix']}-#{u['id']}.#{ext}" do
          action :delete
        end
      end
    end
  end
end
