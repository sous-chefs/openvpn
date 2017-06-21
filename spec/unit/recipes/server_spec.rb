require 'spec_helper'

describe 'openvpn::server' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['openvpn_conf']) do |node|
      node.override['openvpn']['push_options'] = {
        'dhcp-options' => ['DOMAIN local',
                           'DOMAIN-SEARCH local'],
      }
      node.override['openvpn']['push_routes'] = [
        '192.168.10.0 255.255.255.0', '10.12.10.0 255.255.255.0'
      ]
      # node.set['openvpn']['key']['org'] = 'testorg'
    end.converge(described_recipe)
  end

  it 'converges' do
    chef_run
  end

  it 'makes a server.conf from template with dhcp options' do
    expect(chef_run).to render_file('/etc/openvpn/server.conf')
      .with_content('push "dhcp-options DOMAIN local"')
    expect(chef_run).to render_file('/etc/openvpn/server.conf')
      .with_content('push "dhcp-options DOMAIN-SEARCH local"')
  end

  it 'makes a server.conf from template with multiple push routes' do
    expect(chef_run).to render_file('/etc/openvpn/server.conf')
      .with_content('push "route 192.168.10.0 255.255.255.0"')
    expect(chef_run).to render_file('/etc/openvpn/server.conf')
      .with_content('push "route 10.12.10.0 255.255.255.0"')
  end

  context 'crl is older than index.txt' do
    before(:each) do
      allow(::FileUtils).to receive(:uptodate?).and_return(false)
    end

    it 'executes gencrl with correction parameters' do
      expect(chef_run).to run_execute('gencrl').with(
        environment: { 'KEY_CN' => 'server' },
        command: 'openssl ca -config /etc/openvpn/easy-rsa/openssl.cnf -gencrl ' \
                 '-keyfile /etc/openvpn/keys/ca.key ' \
                 '-cert /etc/openvpn/keys/ca.crt ' \
                 '-out /etc/openvpn/keys/crl.pem'
      )
    end
  end

  context 'crl is newer than index.txt' do
    before(:each) do
      allow(::FileUtils).to receive(:uptodate?).and_return(true)
    end

    it 'does not execute gencrl' do
      expect(chef_run).to_not run_execute('gencrl')
    end
  end

  it 'gencrl notifies remote_file[/etc/openvpn/crl.pem]' do
    expect(chef_run.execute('gencrl'))
      .to notify('remote_file[/etc/openvpn/crl.pem]').to(:create).delayed
  end

  it 'creates a world readable CRL file' do
    expect(chef_run).to create_remote_file('/etc/openvpn/crl.pem').with(
      mode: '644',
      source: 'file:///etc/openvpn/keys/crl.pem'
    )
  end
end
