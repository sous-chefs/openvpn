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
  end
else
  describe service('openvpn') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end

describe file('/etc/openvpn/server.conf') do
  its('content') { should include 'push "dhcp-option DOMAIN local"' }
  its('content') { should include 'push "dhcp-option DOMAIN-SEARCH local"' }
  its('content') { should include 'push "route 192.168.10.0 255.255.255.0"' }
  its('content') { should include 'push "route 10.12.10.0 255.255.255.0"' }
end

describe file('/etc/openvpn/easy-rsa/pkitool') do
  its('content') { should include '-md sha256' }
end

describe command('openssl crl -in /etc/openvpn/keys/crl.pem -noout -issuer') do
  its(:stdout) do
    is_expected.to eq(
      'issuer=/C=US/ST=CA/L=San Francisco/O=Fort Funston/OU=OpenVPN ' \
      "Server/CN=server/emailAddress=admin@foobar.com\n"
    )
  end
end
