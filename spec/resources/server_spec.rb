# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_server' do
  step_into :openvpn_server
  platform 'ubuntu', '22.04'

  context 'create action with defaults' do
    recipe do
      openvpn_server 'default'
    end

    it { is_expected.to create_directory('/etc/openvpn/keys').with(mode: '0700', recursive: true) }
    it { is_expected.to create_directory('/etc/openvpn/easy-rsa').with(mode: '0755') }

    %w(openssl.cnf pkitool vars Rakefile).each do |f|
      it { is_expected.to create_template("/etc/openvpn/easy-rsa/#{f}") }
    end

    it { is_expected.to create_template('/etc/openvpn/server.up.sh').with(mode: '0755') }
    it { is_expected.to create_directory('/etc/openvpn/server.up.d').with(mode: '0755') }
    it { is_expected.to create_template('/etc/openvpn/keys/openssl.cnf').with(mode: '0644') }
    it { is_expected.to create_file('/etc/openvpn/keys/index.txt').with(mode: '0600') }
    it { is_expected.to create_if_missing_file('/etc/openvpn/keys/serial') }
    it { is_expected.to create_if_missing_file('/etc/openvpn/keys/dh2048.pem').with(mode: '0600') }
    it { is_expected.to run_execute('openvpn-initca') }
    it { is_expected.to run_execute('openvpn-server-key') }
    it { is_expected.to run_execute('gencrl') }
    it { is_expected.to create_remote_file('/etc/openvpn/crl.pem').with(mode: '0644') }
  end

  context 'create action with custom PKI properties' do
    recipe do
      openvpn_server 'custom' do
        key_dir '/opt/openvpn/keys'
        easy_rsa_dir '/opt/openvpn/easy-rsa'
        key_org 'Test Org'
        key_email 'test@example.com'
        server_up_script false
      end
    end

    it { is_expected.to create_directory('/opt/openvpn/keys') }
    it { is_expected.to create_directory('/opt/openvpn/easy-rsa') }
    it { is_expected.not_to create_template('/etc/openvpn/server.up.sh') }
    it { is_expected.not_to create_directory('/etc/openvpn/server.up.d') }
  end
end
