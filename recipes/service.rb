#
# Cookbook Name:: openvpn
# Recipe:: service
#
# Copyright 2009-2013, Chef Software, Inc.
# Copyright 2015, Chef Software, Inc. <legal@chef.io>
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

include_recipe 'openvpn::install'

# systemd platforms use an instance service
case node['platform_family']
when 'rhel'
  if node['platform_version'] >= '7'
    link '/etc/systemd/system/multi-user.target.wants/openvpn@server.service' do
      to '/usr/lib/systemd/system/openvpn@.service'
    end
    service_name = 'openvpn@server.service'
  else
    service_name = 'openvpn'
  end
when 'arch'
  service_name = 'openvpn@server.service'
else
  service_name = 'openvpn'
end

service 'openvpn' do
  service_name service_name
  action [:enable, :start]
end
