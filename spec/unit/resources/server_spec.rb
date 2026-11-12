# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_server' do
  step_into :openvpn_server
  platform 'ubuntu', '24.04'

  recipe do
    openvpn_server 'server' do
      key_size 512
      config(
        'ca' => '/etc/openvpn/keys/ca.crt',
        'cert' => '/etc/openvpn/keys/server.crt',
        'crl-verify' => '/etc/openvpn/crl.pem',
        'dev' => 'tun0',
        'dh' => '/etc/openvpn/keys/dh512.pem',
        'key' => '/etc/openvpn/keys/server.key',
        'port' => '1194',
        'proto' => 'udp',
        'server' => '10.8.0.0 255.255.0.0'
      )
    end
  end

  it { is_expected.to install_openvpn_install('default') }
  it { is_expected.to create_directory('/etc/openvpn/keys') }
  it { is_expected.to create_file_if_missing('/etc/sysctl.conf') }
  it { is_expected.to create_directory('/etc/openvpn/easy-rsa') }
  it { is_expected.to create_template('/etc/openvpn/easy-rsa/openssl.cnf') }
  it { is_expected.to create_template('/etc/openvpn/server.up.sh') }
  it { is_expected.to create_file_if_missing('/etc/openvpn/keys/dh512.pem') }
  it { is_expected.to run_execute('openvpn-initca') }
  it { is_expected.to run_execute('openvpn-server-key') }
  it { is_expected.to create_openvpn_conf('server') }
  it { is_expected.to enable_openvpn_service('server') }
  it { is_expected.to start_openvpn_service('server') }

  context 'with a named RHEL instance and partial configuration' do
    platform 'almalinux', '9'

    recipe do
      openvpn_server 'office' do
        config('port' => '1195')
      end
    end

    it 'uses the distribution server directory and retains required PKI defaults' do
      resource = chef_run.openvpn_conf('office')
      expect(resource.config_path).to eq('/etc/openvpn/server/office.conf')
      expect(resource.config).to include('port' => '1195', 'dh' => '/etc/openvpn/keys/dh2048.pem')
    end
  end

  context 'deleting a named RHEL server' do
    platform 'almalinux', '9'

    recipe do
      openvpn_server 'office' do
        action :delete
      end
    end

    it 'stops the server unit rather than deriving its type from the instance name' do
      expect(chef_run.openvpn_service('office').service_type).to eq('server')
    end
    it { is_expected.to delete_openvpn_conf('office').with(config_path: '/etc/openvpn/server/office.conf') }
  end
end
