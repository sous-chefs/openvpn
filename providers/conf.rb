#
# Cookbook Name:: openvpn
# Provider:: conf
#
# Copyright 2013, Tacit Knowledge, Inc.
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

use_inline_resources

action :create do
  vars = {
    :log => new_resource.log, :port => new_resource.port,
    :proto => new_resource.proto, :type => new_resource.type,
    :local => new_resource.local, :routes => new_resource.routes,
    :script_security => new_resource.script_security,
    :key_dir => new_resource.key_dir, :key_size => new_resource.key_size,
    :subnet => new_resource.subnet, :netmask => new_resource.netmask,
    :user => new_resource.user, :group => new_resource.group,
    :verb => new_resource.verb, :mute => new_resource.mute,
    :dhcp_dns => new_resource.dhcp_dns, :tls_key => new_resource.tls_key,
    :dhcp_domain => new_resource.dhcp_domain,
    :duplicate_cn => new_resource.duplicate_cn,
    :interface_num => new_resource.interface_num,
    :client_subnet_route => new_resource.client_subnet_route,
    :max_clients => new_resource.max_clients,
    :status_log => new_resource.status_log,
    :plugins => new_resource.plugins
  }

  template "/etc/openvpn/#{new_resource.name}.conf" do
    source 'server.conf.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables vars
  end
end

action :delete do
  file "/etc/openvpn/#{new_resource.name}.conf" do
    action :delete
  end
end
