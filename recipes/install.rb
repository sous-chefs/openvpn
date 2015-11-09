#
# Cookbook Name:: openvpn
# Recipe:: install
#
# Copyright 2014, Xhost Australia
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

# Make sure the Apt cache is updated
if platform_family?('debian')
  node.override['apt']['compile_time_update'] = true
  include_recipe 'apt'
end

include_recipe 'yum-epel' if platform_family?('rhel')

# ldap requires building from source
if node['openvpn']['install_from_source'] || node['openvpn']['ldap']['config']['server']
  include_recipe 'openvpn::source'
else
  package 'openvpn'
end

if node['openvpn']['duo']['config']['ikey'] &&
   node['openvpn']['duo']['config']['skey'] &&
   node['openvpn']['duo']['config']['host']

  include_recipe 'openvpn::duo'
end

if node['openvpn']['ldap']['config']['server']
  include_recipe 'openvpn::ldap'
end
