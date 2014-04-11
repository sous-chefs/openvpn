
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

include Chef::DSL::IncludeRecipe

action :create do
  directory dir_path

  template conf_path do
    source 'client.conf.erb'
    cookbook 'openvpn'
    owner 'root'
    group 'root'
    mode 0755
    variables :conf => new_resource.conf
    notifies :start, service_instance if new_resource.autostart
  end

  file autostart_path do
    action new_resource.autostart ? :create : :delete
  end
end

action :delete do
  file conf_path do
    action :delete
    notifies :stop, service_instance
  end

  file autostart_path do
    action :delete
  end
end

def initialize(name, run_context = nil)
  super
  include_recipe 'openvpn::client'
end

def dir_path
  ::File.join(node['openvpn']['conf_d_dir'], new_resource.instance)
end

def conf_path
  ::File.join(dir_path, 'conf')
end

def autostart_path
  ::File.join(dir_path, 'autostart')
end

def service_instance
  service "openvpn-#{new_resource.instance}" do
    start_command "service openvpn-instance start NAME=#{new_resource.instance}"
    stop_command "service openvpn-instance stop NAME=#{new_resource.instance}"
    action :nothing
  end
  return "service[openvpn-#{new_resource.instance}]"
end
