#
# Cookbook:: openvpn
# Recipe:: service
#
# Copyright:: 2009-2019, Chef Software, Inc.
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
  case node['platform_version'].to_i
  when 8
    link "/etc/systemd/system/multi-user.target.wants/openvpn-#{node['openvpn']['type']}@#{node['openvpn']['type']}.service" do
      to '/usr/lib/systemd/system/openvpn@.service'
    end
    service_name = "openvpn-#{node['openvpn']['type']}@#{node['openvpn']['type']}.service"
  when 7
    link "/etc/systemd/system/multi-user.target.wants/openvpn@#{node['openvpn']['type']}.service" do
      to '/usr/lib/systemd/system/openvpn@.service'
    end
    service_name = "openvpn@#{node['openvpn']['type']}.service"
  else
    service_name = 'openvpn'
  end
when 'fedora'
  link "/etc/systemd/system/multi-user.target.wants/openvpn-#{node['openvpn']['type']}@#{node['openvpn']['type']}.service" do
    to '/usr/lib/systemd/system/openvpn@.service'
  end
  service_name = "openvpn-#{node['openvpn']['type']}@#{node['openvpn']['type']}.service"
when 'amazon'
  case node['platform_version'].to_i
  when 2
    link "/etc/systemd/system/multi-user.target.wants/openvpn@#{node['openvpn']['type']}.service" do
      to '/usr/lib/systemd/system/openvpn@.service'
    end
    service_name = "openvpn@#{node['openvpn']['type']}.service"
  else
    service_name = 'openvpn'
  end
when 'debian'
  service_name = "openvpn@#{node['openvpn']['type']}.service"
when 'arch'
  if node['openvpn']['git_package']
    link "#{node['openvpn']['fs_prefix']}/etc/openvpn/#{node['openvpn']['type']}/#{node['openvpn']['type']}.conf" do
      to "#{node['openvpn']['fs_prefix']}/etc/openvpn/#{node['openvpn']['type']}.conf"
    end
    service_name = "openvpn-#{node['openvpn']['type']}@#{node['openvpn']['type']}.service"
  else
    service_name = "openvpn@#{node['openvpn']['type']}.service"
  end
else
  service_name = 'openvpn'
end

service 'openvpn' do
  service_name service_name
  action [:enable, :start]
end
