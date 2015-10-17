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

  describe file('/etc/openvpn/easy-rsa/pkitool') do
    describe '#content' do
      subject { super().content }
      it { is_expected.to include '-md sha1' }
    end
  end
end
