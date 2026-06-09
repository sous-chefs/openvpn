# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_service' do
  step_into :openvpn_service

  context 'on ubuntu' do
    platform 'ubuntu', '22.04'

    context 'create action' do
      recipe do
        openvpn_service 'default' do
          vpn_type 'server'
        end
      end

      it { is_expected.to enable_service('openvpn').with(service_name: 'openvpn@server.service') }
      it { is_expected.to start_service('openvpn').with(service_name: 'openvpn@server.service') }
    end

    context 'delete action' do
      recipe do
        openvpn_service 'default' do
          action :delete
        end
      end

      it { is_expected.to stop_service('openvpn') }
      it { is_expected.to disable_service('openvpn') }
    end
  end

  context 'on almalinux' do
    platform 'almalinux', '9'

    context 'create action' do
      recipe do
        openvpn_service 'default' do
          vpn_type 'server'
        end
      end

      it { is_expected.to enable_service('openvpn').with(service_name: 'openvpn-server@server.service') }
      it { is_expected.to start_service('openvpn').with(service_name: 'openvpn-server@server.service') }
      it { is_expected.to create_link('/etc/systemd/system/multi-user.target.wants/openvpn-server@server.service') }
    end
  end
end
