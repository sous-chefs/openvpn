# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_conf' do
  step_into :openvpn_conf
  platform 'ubuntu', '24.04'

  context 'with explicit config' do
    recipe do
      openvpn_conf 'server' do
        config(
          'dev' => 'tun0',
          'port' => '1194',
          'proto' => 'udp'
        )
        push_routes ['192.168.10.0 255.255.255.0']
        push_options('dhcp-option' => ['DOMAIN local'])
      end
    end

    it { is_expected.to create_directory('/etc/openvpn') }
    it { is_expected.to create_template('/etc/openvpn/server.conf') }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content('dev tun0') }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content('push "route 192.168.10.0 255.255.255.0"') }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content('push "dhcp-option DOMAIN local"') }
  end

  context 'on rhel family' do
    platform 'almalinux', '9'

    recipe do
      openvpn_conf 'server'
    end

    it { is_expected.to create_directory('/etc/openvpn/server') }
    it { is_expected.to create_template('/etc/openvpn/server/server.conf') }
  end
end
