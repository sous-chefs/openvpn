# Encoding: utf-8
require 'serverspec'

set :backend, :exec

context 'Config' do
  %w(
    /etc/openvpn/easy-rsa/Rakefile
    /etc/openvpn/keys/vpn-prod-vpn_user.conf
    /etc/openvpn/keys/vpn-prod-vpn_user.ovpn
  ).each do |file|
    describe file(file) do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include 'remote-cert-tls server' }
      end
    end
  end
end
