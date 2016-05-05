# Encoding: utf-8
require 'spec_helper'

context 'Config' do
  describe service('openvpn') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

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
      it { is_expected.to include '-md sha256' }
    end
  end

  describe file('/etc/openvpn/keys/crl.pem') do
    describe '#content' do
      subject { super().content }
    end
    it { is_expected.to be_file }
  end

  describe command('openssl crl -in /etc/openvpn/keys/crl.pem -noout -issuer') do
    its(:stdout) do
      is_expected.to eq(
        'issuer=/C=US/ST=CA/L=San Francisco/O=Fort Funston/OU=OpenVPN ' \
        "Server/CN=server/emailAddress=admin@foobar.com\n"
      )
    end
  end
end
