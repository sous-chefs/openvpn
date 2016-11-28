require 'spec_helper'

describe 'openvpn::users' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new(step_into: ['openvpn_users']) do |node, server|
      server.create_data_bag(
        'users', user: { id: 'user' },
                 removeduser: { id: 'removeduser', action: 'remove' })
      node.set['openvpn']['gateway'] = 'vpn.test.local'
      node.set['openvpn']['config']['port'] = 1111
    end.converge(described_recipe)
  end

  it 'converges' do
    chef_run
  end

  it 'runs openvpn_users with [:create, :remove]' do
    expect(chef_run).to create_openvpn_users('users')
    expect(chef_run).to remove_openvpn_users('users')
  end

  it 'creates user: user' do
    expect(chef_run).to run_execute('generate-openvpn-user').with(command: './pkitool user')
    expect(chef_run).to run_execute('create-openvpn-tar-user')
  end

  it 'creates user: user' do
    expect(chef_run).to run_execute('generate-openvpn-user').with(
      command: './pkitool user'
    )
    expect(chef_run).to run_execute('create-openvpn-tar-user')
  end

  it 'makes a .conf and .ovpn files for user' do
    expect(chef_run).to render_file('/etc/openvpn/keys/vpn-prod-user.conf')
      .with_content('cert user.crt')
      .with_content('key user.key')
      .with_content('remote vpn.test.local 1111')
    expect(chef_run).to render_file('/etc/openvpn/keys/vpn-prod-user.ovpn')
      .with_content('cert user.crt')
      .with_content('key user.key')
      .with_content('remote vpn.test.local 1111')
  end

  it 'deletes certificates of removeduser' do
    expect(chef_run).to delete_file('/etc/openvpn/keys/removeduser.tar.gz')
    expect(chef_run).to delete_file('/etc/openvpn/keys/removeduser.crt')
    expect(chef_run).to delete_file('/etc/openvpn/keys/removeduser.key')
    expect(chef_run).to delete_file('/etc/openvpn/keys/removeduser.csr')
    expect(chef_run).to delete_file('/etc/openvpn/keys/vpn-prod-removeduser.ovpn')
    expect(chef_run).to delete_file('/etc/openvpn/keys/vpn-prod-removeduser.conf')
  end

  context 'removing user with valid cert' do
    before(:each) do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/openvpn/keys/removeduser.crt').and_return(true)
      allow(OpenVPN::Helper).to receive(:cert_valid?).and_return(true)
    end
    it 'revokes removeduser cert' do
      expect(chef_run).to run_execute('revoke-openvpn-removeduser').with(
        command: '. /etc/openvpn/easy-rsa/vars && openssl ca -revoke' \
                 ' /etc/openvpn/keys/removeduser.crt -config /etc/openvpn/keys/openssl.cnf'
      )
    end
  end

  context 'removing user with a revoked cert' do
    before(:each) do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/openvpn/keys/removeduser.crt').and_return(true)
      allow(OpenVPN::Helper).to receive(:cert_valid?).and_return(false)
    end
    it 'revokes removeduser cert' do
      expect(chef_run).to_not run_execute('revoke-openvpn-removeduser')
    end
  end
end
