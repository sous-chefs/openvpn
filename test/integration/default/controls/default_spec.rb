# frozen_string_literal: true

title 'OpenVPN Default Tests'

control 'openvpn-install-01' do
  impact 1.0
  title 'OpenVPN package is installed'
  desc 'The openvpn package should be installed'

  describe package('openvpn') do
    it { should be_installed }
  end
end

control 'openvpn-service-01' do
  impact 1.0
  title 'OpenVPN service is running'
  desc 'The openvpn service should be enabled and running'

  if os.family == 'debian'
    describe systemd_service('openvpn@server') do
      it { should be_enabled }
      it { should be_running }
    end
  elsif os.family == 'redhat' || os.family == 'fedora'
    describe systemd_service('openvpn-server@server') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end

control 'openvpn-config-01' do
  impact 1.0
  title 'OpenVPN configuration file exists'
  desc 'The server configuration file should be present with expected content'

  conf_location = if os.family == 'redhat' || os.family == 'fedora'
                    '/etc/openvpn/server/server.conf'
                  else
                    '/etc/openvpn/server.conf'
                  end

  describe file(conf_location) do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'push "route 10.0.0.0 255.255.255.0"' }
  end
end

control 'openvpn-pki-01' do
  impact 1.0
  title 'PKI infrastructure is set up'
  desc 'CA certificate, server certificate, and keys should exist'

  describe file('/etc/openvpn/keys/ca.crt') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/openvpn/keys/server.crt') do
    it { should exist }
    it { should be_file }
  end

  describe file('/etc/openvpn/keys/server.key') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
  end

  describe file('/etc/openvpn/keys/ca.key') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
  end

  describe file('/etc/openvpn/keys/dh2048.pem') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
  end
end

control 'openvpn-pki-02' do
  impact 0.7
  title 'Easy-RSA tools are deployed'
  desc 'The pkitool and supporting files should be deployed'

  describe file('/etc/openvpn/easy-rsa/pkitool') do
    it { should exist }
    its('content') { should include '-md sha256' }
  end
end

control 'openvpn-crl-01' do
  impact 0.7
  title 'CRL is generated'
  desc 'The certificate revocation list should be generated'

  describe file('/etc/openvpn/keys/crl.pem') do
    it { should exist }
  end
end

control 'openvpn-ip-forwarding-01' do
  impact 0.7
  title 'IP forwarding is enabled'
  desc 'IPv4 forwarding should be enabled for VPN traffic'

  describe kernel_parameter('net.ipv4.conf.all.forwarding') do
    its('value') { should eq 1 }
  end
end
