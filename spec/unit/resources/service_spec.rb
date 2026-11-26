# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_service' do
  step_into :openvpn_service

  context 'on ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      openvpn_service 'server' do
        action [:enable, :start]
      end
    end

    it { is_expected.to enable_service('openvpn@server.service') }
    it { is_expected.to start_service('openvpn@server.service') }
  end

  context 'on almalinux' do
    platform 'almalinux', '9'

    recipe do
      openvpn_service 'server' do
        service_type 'server'
        action [:enable, :start]
      end
    end

    it { is_expected.to enable_service('openvpn-server@server.service') }
    it { is_expected.to start_service('openvpn-server@server.service') }
  end

  context 'using a custom configuration on AlmaLinux' do
    platform 'almalinux', '9'

    recipe do
      openvpn_service 'office' do
        service_type 'server'
        config_path '/srv/vpn/office.conf'
        action :start
      end
    end

    it { is_expected.to create_link('/etc/openvpn/server/office.conf').with(to: '/srv/vpn/office.conf') }
    it { is_expected.to start_service('openvpn-server@office.service') }

    context 'when the package path already belongs to another configuration' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/openvpn/server/office.conf').and_return(true)
      end

      it 'fails before replacing the existing configuration' do
        expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed, /configuration already exists/)
      end
    end
  end

  context 'deleting a packaged service with its custom configuration link' do
    platform 'ubuntu', '24.04'

    before do
      allow(File).to receive(:symlink?).and_call_original
      allow(File).to receive(:symlink?).with('/etc/openvpn/office.conf').and_return(true)
      allow(File).to receive(:readlink).with('/etc/openvpn/office.conf').and_return('/srv/vpn/office.conf')
    end

    recipe do
      openvpn_service 'office' do
        service_type 'client'
        config_path '/srv/vpn/office.conf'
        action :delete
      end
    end

    it { is_expected.to delete_link('/etc/openvpn/office.conf') }
    it { is_expected.to stop_service('openvpn@office.service') }
  end
end
