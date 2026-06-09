# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_conf' do
  step_into :openvpn_conf
  platform 'ubuntu', '22.04'

  context 'create action' do
    recipe do
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

  context 'delete action' do
    recipe do
      openvpn_conf 'server' do
        action :delete
      end
    end

    it { is_expected.to delete_file('/etc/openvpn/server.conf') }
  end
end
