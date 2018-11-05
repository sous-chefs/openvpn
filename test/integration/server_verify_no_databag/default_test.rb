describe file('/etc/openvpn/easy-rsa/Rakefile') do
  describe '#content' do
    subject { super().content }
    it { is_expected.to include 'remote-cert-tls server' }
  end
end

describe file('/etc/openvpn/keys/vpn-prod-client.ovpn') do
  describe '#content' do
    subject { super().content }
    it { is_expected.to include 'client' }
    it { is_expected.to include '<ca>' }
    it { is_expected.to include '<cert>' }
    it { is_expected.to include '<key>' }
  end
end
