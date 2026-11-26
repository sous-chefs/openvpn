# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn_server' do
  step_into :openvpn_server
  platform 'ubuntu', '24.04'

  recipe do
    openvpn_server 'server' do
      key_size 512
      config(
        'ca' => '/etc/openvpn/keys/ca.crt',
        'cert' => '/etc/openvpn/keys/server.crt',
        'crl-verify' => '/etc/openvpn/crl.pem',
        'dev' => 'tun0',
        'dh' => '/etc/openvpn/keys/dh512.pem',
        'key' => '/etc/openvpn/keys/server.key',
        'port' => '1194',
        'proto' => 'udp',
        'server' => '10.8.0.0 255.255.0.0'
      )
    end
  end

  it { is_expected.to install_openvpn_install('default') }
  it { is_expected.to create_directory('/etc/openvpn/keys') }
  it { is_expected.to create_file_if_missing('/etc/sysctl.conf') }
  it { is_expected.to create_directory('/etc/openvpn/easy-rsa') }
  it { is_expected.to create_directory('/etc/openvpn/server.up.d') }
  it { is_expected.to create_template('/etc/openvpn/easy-rsa/openssl.cnf') }
  it { is_expected.to create_template('/etc/openvpn/server.up.sh') }
  it { is_expected.to render_file('/etc/openvpn/server.up.sh').with_content('net.ipv4.ip_forward=1') }
  it { is_expected.not_to render_file('/etc/openvpn/easy-rsa/Rakefile').with_content(/^remote-cert-tls /) }
  it { is_expected.to create_file_if_missing('/etc/openvpn/keys/dh512.pem') }
  it { is_expected.to run_execute('openvpn-initca') }
  it { is_expected.to run_execute('openvpn-server-key') }
  it { is_expected.to create_openvpn_conf('server') }
  it { is_expected.to enable_openvpn_service('server') }
  it { is_expected.to start_openvpn_service('server') }

  it 'uses the managed startup script in the default configuration' do
    expect(chef_run.openvpn_conf('server').config['up']).to eq('/etc/openvpn/server.up.sh')
  end

  context 'with server verification for manually generated client bundles' do
    recipe do
      openvpn_server 'server' do
        server_verification 'remote-cert-tls server'
      end
    end

    it { is_expected.to render_file('/etc/openvpn/easy-rsa/Rakefile').with_content(/^remote-cert-tls server$/) }
  end

  context 'with host forwarding managed separately and a custom hook directory' do
    recipe do
      openvpn_server 'server' do
        enable_ip_forwarding false
        up_script_dir '/etc/openvpn/custom hooks'
      end
    end

    it { is_expected.not_to render_file('/etc/openvpn/server.up.sh').with_content('/sbin/sysctl') }
    it { is_expected.to render_file('/etc/openvpn/server.up.sh').with_content('/etc/openvpn/custom\ hooks/*.sh') }
  end

  context 'with startup hook management disabled' do
    step_into :openvpn_server, :openvpn_conf

    recipe do
      openvpn_server 'server' do
        server_up_script false
      end
    end

    it { is_expected.not_to create_directory('/etc/openvpn/server.up.d') }
    it { is_expected.not_to create_template('/etc/openvpn/server.up.sh') }
    it { is_expected.not_to render_file('/etc/openvpn/server.conf').with_content(/^up /) }
    it { is_expected.to apply_sysctl('net.ipv4.conf.all.forwarding').with(value: '1') }
  end

  context 'with an operator-managed startup hook and forwarding disabled' do
    step_into :openvpn_server, :openvpn_conf

    recipe do
      openvpn_server 'server' do
        server_up_script false
        up_script_path '/etc/openvpn/operator-up.sh'
        enable_ip_forwarding false
        config('up' => '/etc/openvpn/operator-up.sh', 'script-security' => 3)
      end
    end

    it { is_expected.not_to create_template('/etc/openvpn/operator-up.sh') }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content(%r{^up /etc/openvpn/operator-up\.sh$}) }
    it { is_expected.to render_file('/etc/openvpn/server.conf').with_content(/^script-security 3$/) }
    it { is_expected.not_to apply_sysctl('net.ipv4.conf.all.forwarding') }
  end

  context 'with a named RHEL instance and partial configuration' do
    platform 'almalinux', '9'

    recipe do
      openvpn_server 'office' do
        config('port' => '1195')
      end
    end

    it 'uses the distribution server directory and retains required PKI defaults' do
      resource = chef_run.openvpn_conf('office')
      expect(resource.config_path).to eq('/etc/openvpn/server/office.conf')
      expect(resource.config).to include('port' => '1195', 'dh' => '/etc/openvpn/keys/dh2048.pem')
    end
  end

  context 'with legacy push options' do
    step_into :openvpn_server, :openvpn_conf

    recipe do
      openvpn_server 'server' do
        push_options [
          ['dhcp-option DNS', '192.0.2.53'],
          ['dhcp-option', 'DOMAIN example.test'],
          ['dhcp-option DNS', '192.0.2.53'],
        ]
      end
    end

    it 'renders the array through the server resource' do
      expect(chef_run).to render_file('/etc/openvpn/server.conf').with_content(<<~CONFIG)
        push "dhcp-option DNS 192.0.2.53"
        push "dhcp-option DOMAIN example.test"
        push "dhcp-option DNS 192.0.2.53"
      CONFIG
    end
  end

  context 'deleting a named RHEL server' do
    platform 'almalinux', '9'

    recipe do
      openvpn_server 'office' do
        action :delete
      end
    end

    it 'stops the server unit rather than deriving its type from the instance name' do
      expect(chef_run.openvpn_service('office').service_type).to eq('server')
    end
    it { is_expected.to delete_openvpn_conf('office').with(config_path: '/etc/openvpn/server/office.conf') }
    it { is_expected.to delete_file('/etc/openvpn/server.up.sh') }
  end

  context 'deleting a server with an operator-managed startup hook' do
    recipe do
      openvpn_server 'server' do
        server_up_script false
        up_script_path '/etc/openvpn/operator-up.sh'
        up_script_dir '/etc/openvpn/operator-up.d'
        action :delete
      end
    end

    it { is_expected.not_to delete_file('/etc/openvpn/operator-up.sh') }
    it { is_expected.not_to delete_directory('/etc/openvpn/operator-up.d') }
    it { is_expected.to delete_file('/etc/openvpn/crl.pem') }
  end
end
