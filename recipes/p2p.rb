#
# Cookbook Name:: openvpn
# Recipe: p2p
#
# Copyright 2009-2013, Opscode, Inc.
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

name                                         = node['openvpn']['name']
node.default['openvpn']['config']['secret']          = "#{name}.key"
node.default['openvpn']['config']['server']          = nil
node.default['openvpn']['config']['ca']              = nil
node.default['openvpn']['config']['key']             = nil
node.default['openvpn']['config']['cert']            = nil
node.default['openvpn']['config']['dh']              = nil

include_recipe 'yum-epel' if platform_family?('rhel')

# Force installation of openvpn package before generating a key with the library
p = package 'openvpn' do
  action :nothing
end
p.run_action(:install)

key = OpenVPN::Keys::SharedKey.new(name)

openvpn_conf name do
  action :create
end

template "/etc/openvpn/#{name}.key" do
  source "key.erb"
  owner 'root'
  group 'root'
  mode '0400'
  variables(
    :key => key.key
  )
  action :create
end

template "/etc/openvpn/#{name}.up.sh" do
  source 'server.up.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[openvpn]'
end

directory "/etc/openvpn/#{name}.up.d" do
  owner 'root'
  group 'root'
  mode '0755'
end

service 'openvpn' do
  action :enable
end
