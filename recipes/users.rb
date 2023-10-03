#
# Cookbook:: openvpn
# Recipe:: users
#
# Copyright:: 2010-2019, Chef Software, Inc.
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

if node['openvpn']['use_databag']
  search(node['openvpn']['user_databag'], node['openvpn']['user_query']) do |u|
    openvpn_user u['id'] do
      key_vars({
        'key_country'  => u['key_country'],
        'key_province' => u['key_province'],
        'key_city'     => u['key_city'],
        'key_email'    => u['key_email'],
        'key_size'     => u['key_size'],
        'key_org'      => u['key_org'],
        'key_org_unit' => u['key_org_unit'],
      })
      create_bundle true
    end
  end
else
  openvpn_user node['openvpn']['client_cn'] do
    create_bundle false
  end
end
