# frozen_string_literal: true

control 'openvpn-package-01' do
  impact 1.0
  title 'OpenVPN package is installed'

  describe package('openvpn') do
    it { should be_installed }
  end
end

control 'openvpn-config-01' do
  impact 1.0
  title 'OpenVPN server configuration exists'

  config_path = if os.family == 'redhat' || os.name == 'fedora' || os.name == 'amazon'
                  '/etc/openvpn/server/server.conf'
                else
                  '/etc/openvpn/server.conf'
                end

  describe file(config_path) do
    it { should exist }
    its('content') { should match(/^proto udp$/) }
    its('content') { should match(/^port 1194$/) }
    its('content') { should match(/^push "route 192\.168\.10\.0 255\.255\.255\.0"$/) }
  end
end

control 'openvpn-pki-01' do
  impact 1.0
  title 'OpenVPN PKI files exist'

  %w(ca.crt ca.key server.crt server.key dh2048.pem).each do |file_name|
    describe file("/etc/openvpn/keys/#{file_name}") do
      it { should exist }
    end
  end
end

control 'openvpn-service-01' do
  impact 0.8
  title 'OpenVPN service is installed'

  service_name = if os.family == 'redhat' || os.name == 'fedora' || os.name == 'amazon'
                   'openvpn-server@server'
                 else
                   'openvpn@server'
                 end

  describe systemd_service(service_name) do
    it { should be_installed }
    it { should be_enabled }
  end
end
