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
  its('content') { should match /C=CA/ }
  its('content') { should match /ST=Ontario/ }
  its('content') { should match /L=Ottawa/ }
  its('content') { should match /O=Test Org/ }
  its('content') { should match /OU=Test Org Unit/ }
  its('content') { should match %r{CN=vpn_user/emailAddress=vpn_user@test.com} }
  its('content') { should match /Public-Key: \(1024 bit\)/ }
end
