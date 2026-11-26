# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_client' do
  step_into :openvpn_client, :openvpn_conf, :openvpn_service

  shared_examples 'a client instance' do |config_path, service_name|
    recipe do
      openvpn_client 'office' do
        config('client' => '', 'dev' => 'tun', 'remote' => 'vpn.example.test 1194')
      end
    end

    it { is_expected.to install_openvpn_install('client-office') }
    it { is_expected.to render_file(config_path).with_content(/^remote vpn.example.test 1194$/) }
    it { is_expected.to enable_service(service_name) }
    it { is_expected.to start_service(service_name) }

    it 'restarts the client instance when configuration changes' do
      expect(chef_run.openvpn_conf('office')).to notify('openvpn_service[office]').to(:restart).delayed
    end
  end

  context 'on Ubuntu' do
    platform 'ubuntu', '24.04'
    include_examples 'a client instance', '/etc/openvpn/office.conf', 'openvpn@office.service'
  end

  context 'on AlmaLinux' do
    platform 'almalinux', '9'
    include_examples 'a client instance', '/etc/openvpn/client/office.conf', 'openvpn-client@office.service'
  end

  context 'deleting a client' do
    platform 'almalinux', '9'

    recipe do
      openvpn_client 'office' do
        action :delete
      end
    end

    it { is_expected.to stop_service('openvpn-client@office.service') }
    it { is_expected.to disable_service('openvpn-client@office.service') }
    it { is_expected.to delete_file('/etc/openvpn/client/office.conf') }
    it { is_expected.not_to install_openvpn_install('client-office') }
  end

  context 'on Red Hat' do
    platform 'redhat', '9'
    include_examples 'a client instance', '/etc/openvpn/client/office.conf', 'openvpn-client@office.service'
  end

  context 'on Arch' do
    platform 'arch', '4.10.13-1-ARCH'
    include_examples 'a client instance', '/etc/openvpn/client/office.conf', 'openvpn-client@office.service'
  end
end
