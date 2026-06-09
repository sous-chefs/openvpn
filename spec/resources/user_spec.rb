# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_user' do
  step_into [:openvpn_user, :openvpn_server]
  platform 'ubuntu', '22.04'

  context 'create action with defaults' do
    recipe do
      openvpn_server 'default'
      openvpn_user 'testuser'
    end

    it { is_expected.to run_execute('generate-openvpn-testuser') }
    it { is_expected.to create_template('/etc/openvpn/keys/vpn-prod-testuser.conf') }
    it { is_expected.to create_template('/etc/openvpn/keys/vpn-prod-testuser.ovpn') }
    it { is_expected.to run_execute('create-openvpn-tar-testuser') }
  end

  context 'create action without bundle' do
    recipe do
      openvpn_server 'default'
      openvpn_user 'testuser' do
        create_bundle false
      end
    end

    it { is_expected.to run_execute('generate-openvpn-testuser') }
    it { is_expected.not_to create_template('/etc/openvpn/keys/vpn-prod-testuser.conf') }
    it { is_expected.to create_template('/etc/openvpn/keys/vpn-prod-testuser.ovpn') }
  end

  context 'create action with custom properties' do
    recipe do
      openvpn_server 'default' do
        key_dir '/opt/keys'
        easy_rsa_dir '/opt/easy-rsa'
      end
      openvpn_user 'customuser' do
        client_prefix 'vpn-test'
        key_dir '/opt/keys'
        easy_rsa_dir '/opt/easy-rsa'
        destination '/opt/keys'
      end
    end

    it { is_expected.to run_execute('generate-openvpn-customuser') }
    it { is_expected.to create_template('/opt/keys/vpn-test-customuser.conf') }
    it { is_expected.to create_template('/opt/keys/vpn-test-customuser.ovpn') }
  end

  context 'delete action' do
    recipe do
      openvpn_user 'testuser' do
        action :delete
      end
    end

    it { is_expected.to delete_file('/etc/openvpn/keys/vpn-prod-testuser.conf') }
    it { is_expected.to delete_file('/etc/openvpn/keys/vpn-prod-testuser.ovpn') }
  end
end
