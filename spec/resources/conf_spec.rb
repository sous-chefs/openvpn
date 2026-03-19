# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_conf' do
  step_into :openvpn_conf
  platform 'ubuntu', '22.04'

  context 'create action' do
    recipe do
      node.default['openvpn']['fs_prefix'] = ''
      node.default['openvpn']['config'] = {}
      node.default['openvpn']['push_routes'] = []
      node.default['openvpn']['push_options'] = {}
      node.default['openvpn']['client_cn'] = []
      openvpn_conf 'server' do
        config(
          'port' => '1194',
          'proto' => 'udp',
          'dev' => 'tun'
        )
        push_routes ['10.0.0.0 255.255.255.0']
      end
    end

    it { is_expected.to create_template('/etc/openvpn/server.conf') }
  end

  # NOTE: The :delete action has a bug — it references `conf_location` which is
  # a local variable scoped to the :create action block. This needs fixing in
  # the resource before it can be tested.
end
