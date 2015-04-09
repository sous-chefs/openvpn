# Encoding: utf-8
require 'spec_helper'

context 'Config' do
  describe file('/etc/openvpn/server.conf') do
    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'push "dhcp-option DOMAIN local"' }
      it { is_expected.to include 'push "dhcp-option DOMAIN-SEARCH local"' }
    end
  end
end
