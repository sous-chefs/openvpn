# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_install' do
  step_into :openvpn_install

  context 'on ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      openvpn_install 'default'
    end

    it { is_expected.to install_package('openvpn') }
    it { is_expected.to install_package('tar') }
    it { is_expected.to install_package('bash') }
    it { is_expected.not_to install_package('epel-release') }
  end

  context 'on almalinux' do
    platform 'almalinux', '9'

    recipe do
      openvpn_install 'default'
    end

    it { is_expected.to install_package('epel-release') }
    it { is_expected.to install_package('openvpn') }
  end
end
