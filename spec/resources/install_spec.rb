# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_install' do
  step_into :openvpn_install
  platform 'ubuntu', '22.04'

  context 'default install' do
    recipe do
      openvpn_install 'default'
    end

    it { is_expected.to install_package('openvpn') }
    it { is_expected.to install_package('tar') }
  end
end
