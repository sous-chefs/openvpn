#
# Cookbook Name:: openvpn
# Resource:: conf
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

actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :port, :kind_of => String
attribute :proto, :kind_of => String
attribute :type, :kind_of => String
attribute :local, :kind_of => String
attribute :routes, :kind_of => Array
attribute :script_security, :kind_of => Integer
attribute :key_dir, :kind_of => String
attribute :key_size, :kind_of => Integer
attribute :subnet, :kind_of => String
attribute :netmask, :kind_of => String
attribute :user, :kind_of => String
attribute :group, :kind_of => String
attribute :log, :kind_of => String
attribute :verb, :kind_of => Integer, :default => 1
attribute :mute, :kind_of => Integer, :default => 10
attribute :dhcp_dns, :kind_of => String
attribute :dhcp_domain, :kind_of => String
attribute :tls_key, :kind_of => String
attribute :duplicate_cn, :kind_of => [TrueClass, FalseClass], :default => false
attribute :interface_num, :kind_of => Integer
attribute :client_subnet_route, :kind_of => String
attribute :max_clients, :kind_of => Integer
attribute :status_log, :kind_of => String, :default => '/etc/openvpn/openvpn-status.log'
attribute :plugins, :kind_of => Array, :default => []
