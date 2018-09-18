#
# Cookbook:: openvpn
# Recipe:: users
#
# Copyright:: 2010-2018, Chef Software, Inc.
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

def chef_solo_search_installed?
  klass = ::Search.const_get('Helper')
  klass.is_a?(Class)
rescue NameError
  false
end

if node['openvpn']['use_databag']
  if Chef::Config[:solo] && !chef_solo_search_installed?
    Chef::Log.warn('This recipe uses search. Chef-Solo does not support search unless '\
      'you install the chef-solo-search cookbook.')
  else
    search(node['openvpn']['user_databag'], node['openvpn']['user_query']) do |u|
      openvpn_user u['id'] do
        create_bundle true
      end
    end
  end
else
  openvpn_user node['openvpn']['client_cn'] do
    create_bundle false
  end
end
