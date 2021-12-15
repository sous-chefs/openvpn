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

describe file('/etc/openvpn/keys/vpn_user.crt') do
  describe '#content' do
    subject { super().content }
    it { is_expected.to include 'C=CA' }
    it { is_expected.to include 'ST=Ontario' }
    it { is_expected.to include 'L=Ottawa' }
    it { is_expected.to include 'O=Test Org' }
    it { is_expected.to include 'OU=Test Org Unit' }
    it { is_expected.to include 'CN=vpn_user/emailAddress=vpn_user@test.com' }
    it { is_expected.to include 'Public-Key: (1024 bit)' }
  end
end
