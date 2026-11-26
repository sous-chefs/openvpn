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
        push_options('dhcp-option' => ['DOMAIN local', 'DNS 192.0.2.53'], 'redirect-gateway' => 'def1')
      end
    end

    it { is_expected.to create_directory('/etc/openvpn') }
    it { is_expected.to create_template('/etc/openvpn/server.conf') }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content('dev tun0') }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content('push "route 192.168.10.0 255.255.255.0"') }
    it 'renders hash options and their values in order' do
      expect(chef_run).to render_file('/etc/openvpn/server.conf').with_content(<<~CONFIG)
        push "dhcp-option DOMAIN local"
        push "dhcp-option DNS 192.0.2.53"
        push "redirect-gateway def1"
      CONFIG
    end
  end

  context 'with legacy push options from node attributes' do
    recipe do
      node.default['legacy_push_options'] = [
        ['dhcp-option DNS', %w(192.0.2.53 192.0.2.54)],
        ['dhcp-option', 'DOMAIN example.test'],
        ['dhcp-option DNS', '192.0.2.53'],
      ]

      openvpn_conf 'server' do
        push_options node['legacy_push_options']
      end
    end

    it 'preserves the order and repeated directives' do
      expect(chef_run).to render_file('/etc/openvpn/server.conf').with_content(<<~CONFIG)
        push "dhcp-option DNS 192.0.2.53"
        push "dhcp-option DNS 192.0.2.54"
        push "dhcp-option DOMAIN example.test"
        push "dhcp-option DNS 192.0.2.53"
      CONFIG
    end
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
