# Encoding: utf-8
require 'spec_helper'

context 'Config' do
  # this is done in a similar fashion to
  # https://github.com/xhost-cookbooks/openvpn/blob/master/recipes/service.rb
  # ServerSpec docs are lax in terms of possible output values for os[:family]
  # https://github.com/mizzy/specinfra/tree/master/lib/specinfra/helper/detect_os
  case os[:family]
  when 'redhat'
    if os[:release] >= '7'
      describe service('openvpn@server') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
        it { should be_running.under('systemd') }
      end
    else
      describe service('openvpn') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  when 'debian'
    if os[:release] >= '8'
      describe service('openvpn@server') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
        it { should be_running.under('systemd') }
      end
    else
      describe service('openvpn') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  when 'ubuntu'
    if os[:release] >= '15.04'
      describe service('openvpn@server') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
        it { should be_running.under('systemd') }
      end
    else
      describe service('openvpn') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  when 'fedora'
    describe service('openvpn@server') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
      it { should be_running.under('systemd') }
    end
  else
    describe service('openvpn') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  describe file('/etc/openvpn/server.conf') do
    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'push "dhcp-option DOMAIN local"' }
      it { is_expected.to include 'push "dhcp-option DOMAIN-SEARCH local"' }
      it { is_expected.to include 'push "route 192.168.10.0 255.255.255.0"' }
      it { is_expected.to include 'push "route 10.12.10.0 255.255.255.0"' }
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
