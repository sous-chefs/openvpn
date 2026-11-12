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
    it { should be_running }
  end
end

control 'openvpn-client-01' do
  impact 1.0
  title 'Named client configuration and service are managed'

  split_units = os.family == 'redhat' || os.name == 'fedora' || os.name == 'amazon'
  config_path = split_units ? '/etc/openvpn/client/office.conf' : '/etc/openvpn/office.conf'
  service_name = split_units ? 'openvpn-client@office' : 'openvpn@office'

  describe file(config_path) do
    it { should exist }
    its('content') { should match(/^remote 127\.0\.0\.1 1194$/) }
    its('content') { should match(%r{^cert /etc/openvpn/keys/vpn_user.crt$}) }
  end

  describe systemd_service(service_name) do
    it { should be_enabled }
    it { should be_running }
  end
end
