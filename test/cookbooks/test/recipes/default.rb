# frozen_string_literal: true

apt_update

openvpn_install 'default'

openvpn_server 'default' do
  key_org 'Test Org'
  key_email 'test@example.com'
end

openvpn_conf 'server' do
  config(
    'port' => '1194',
    'proto' => 'udp',
    'dev' => 'tun0',
    'server' => '10.8.0.0 255.255.0.0',
    'persist-key' => '',
    'persist-tun' => '',
    'keepalive' => '10 120',
    'user' => 'nobody',
    'group' => 'nogroup',
    'ca' => '/etc/openvpn/keys/ca.crt',
    'cert' => '/etc/openvpn/keys/server.crt',
    'key' => '/etc/openvpn/keys/server.key',
    'dh' => '/etc/openvpn/keys/dh2048.pem',
    'crl-verify' => '/etc/openvpn/crl.pem'
  )
  push_routes ['10.0.0.0 255.255.255.0']
end

openvpn_service 'default' do
  vpn_type 'server'
end
