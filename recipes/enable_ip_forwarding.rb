#
# Cookbook Name:: openvpn
# Recipe:: enable_ip_forwarding
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

include_recipe 'sysctl::default'

sysctl_param 'net.ipv4.conf.all.forwarding' do
  value 1
end

sysctl_param 'net.ipv6.conf.all.forwarding' do
  value 1
end
