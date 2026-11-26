# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_user' do
  step_into :openvpn_user
  platform 'ubuntu', '24.04'

  recipe do
    openvpn_user 'vpn_user' do
      config(
        'dev' => 'tun0',
        'port' => '1194',
        'proto' => 'udp'
      )
      gateway 'vpn.example.test'
      key_dir '/etc/openvpn/keys'
      destination '/etc/openvpn/keys'
    end
  end

  it { is_expected.to create_directory('/etc/openvpn/keys') }
  it { is_expected.to run_execute('generate-openvpn-vpn_user') }
  it { expect(chef_run.execute('gencrl-openvpn-vpn_user').environment).to include('KEY_DIR' => '/etc/openvpn/keys') }
  it { is_expected.to create_template('/etc/openvpn/keys/vpn-prod-vpn_user.conf') }
  it { is_expected.to create_template('/etc/openvpn/keys/vpn-prod-vpn_user.ovpn') }
  it { is_expected.to run_execute('create-openvpn-tar-vpn_user') }
end
