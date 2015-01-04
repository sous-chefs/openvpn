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

use_inline_resources if defined?(use_inline_resources)

action :create do
  template "/etc/openvpn/#{new_resource.name}.conf" do
    cookbook 'openvpn'
    source 'server.conf.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables config: new_resource.config || node['openvpn']['config']
  end
end

action :delete do
  file "/etc/openvpn/#{new_resource.name}.conf" do
    action :delete
  end
end
