#
# Cookbook Name:: openvpn
# Attributes:: openvpn
#
# Copyright 2009-2013, Chef Software, Inc.
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

# Set this to false if you want to just use the lwrp
default['openvpn']['configure_default_server'] = true

# Used by helper library to generate certificates/keys
default['openvpn']['key']['ca_expire']      = 3650
default['openvpn']['key']['expire']         = 3650
default['openvpn']['key']['size']           = 1024
default['openvpn']['key']['country']        = 'US'
default['openvpn']['key']['province']       = 'CA'
default['openvpn']['key']['city']           = 'San Francisco'
default['openvpn']['key']['org']            = 'Fort Funston'
default['openvpn']['key']['email']          = 'admin@foobar.com'
default['openvpn']['key']['message_digest'] = 'sha256'

# Cookbook attributes
default['openvpn']['client_prefix']   = 'vpn-prod'
default['openvpn']['key_dir']         = '/etc/openvpn/keys'
default['openvpn']['signing_ca_key']  = "#{node['openvpn']['key_dir']}/ca.key"
default['openvpn']['signing_ca_cert'] = "#{node['openvpn']['key_dir']}/ca.crt"
default['openvpn']['user_query']      = '*:*'
default['openvpn']['cookbook_user_conf'] = 'openvpn'

default['openvpn']['type']            = 'server'
default['openvpn']['subnet']          = '10.8.0.0'
default['openvpn']['netmask']         = '255.255.0.0'

# Client specific
default['openvpn']['gateway']         = "vpn.#{node['domain']}"
default['openvpn']['client_cn']       = 'client'

# Server specific
# client 'push routes', attribute is treated as a helper
default['openvpn']['push_routes'] = []

# client 'push options', attribute is treated as a helper
default['openvpn']['push_options'] = []

# Direct configuration file directives (.conf) defaults
default['openvpn']['config']['user']  = 'nobody'

# the default follows Linux Standard Base Core Specification (ISO/IEC 23360 Part 1:2007(E)):
# Table 21-2 Optional User & Group Names
default['openvpn']['config']['group'] = value_for_platform_family(rhel: 'nobody',
                                                                  arch: 'nobody',
                                                                  debian: 'nogroup',
                                                                  mac_os_x: 'nogroup',
                                                                  default: 'nobody'
                                                                 )

default['openvpn']['config']['local']           = node['ipaddress']
default['openvpn']['config']['proto']           = 'udp'
default['openvpn']['config']['port']            = '1194'
default['openvpn']['config']['keepalive']       = '10 120'
default['openvpn']['config']['log']             = '/var/log/openvpn.log'
default['openvpn']['config']['push']            = nil
default['openvpn']['config']['script-security'] = 2
default['openvpn']['config']['up']              = '/etc/openvpn/server.up.sh'
default['openvpn']['config']['persist-key']     = ''
default['openvpn']['config']['persist-tun']     = ''
default['openvpn']['config']['comp-lzo']        = ''

default['openvpn']['config']['ca']              = node['openvpn']['signing_ca_cert']
default['openvpn']['config']['key']             = "#{node['openvpn']['key_dir']}/server.key"
default['openvpn']['config']['cert']            = "#{node['openvpn']['key_dir']}/server.crt"
default['openvpn']['config']['dh']              = "#{node['openvpn']['key_dir']}/dh#{node['openvpn']['key']['size']}.pem"
default['openvpn']['config']['crl-verify']      = '/etc/openvpn/crl.pem'

# interface configuration depending on type
case node['openvpn']['type']
when 'client'
  default['openvpn']['config']['client'] = ''
  default['openvpn']['config']['dev'] = 'tun0'
when 'server'
  default['openvpn']['config']['server'] = "#{node['openvpn']['subnet']} #{node['openvpn']['netmask']}"
  default['openvpn']['config']['dev'] = 'tun0'
when 'server-bridge'
  default['openvpn']['config']['dev'] = 'tap0'
end
