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

include Chef::DSL::IncludeRecipe

action :create do
  if new_resource.conf
    template file_path do
      source 'client.conf..erb'
      cookbook 'openvpn'
      owner 'root'
      group 'root'
      mode 0755
      variables :conf => new_resource.conf
      notifies :start, 'service[openvpn-launcher]'
    end
  elsif new_resource.conf_file
    file file_path do
      owner 'root'
      group 'root'
      mode 0755
      content ::File.open(new_resource.conf).read
      action :create
      notifies :start, 'service[openvpn-launcher]'
    end
  end
end

action :delete do
  file file_path do
    action :delete
    notifies :stop, "openvpn[#{new_resource.instance}]"
  end
end

def initialize(name, run_context = nil)
  super
  include_recipe 'openvpn::client'

  service "openvpn #{new_resource.instance}" do
    start_command "service openvpn-instance start CONFIG_FILE=#{file_path}"
    stop_command "service openvpn-instance stop CONFIG_FILE=#{file_path}"
    action :nothing
  end
end

def file_path
  ::File.join(node['openvpn']['conf_dir'], new_resource.instance)
end
