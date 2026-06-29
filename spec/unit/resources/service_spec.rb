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
end
