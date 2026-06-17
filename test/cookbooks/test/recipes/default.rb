# frozen_string_literal: true

openvpn_server 'server' do
  key_size 2048
  config(
    'ca' => '/etc/openvpn/keys/ca.crt',
    'cert' => '/etc/openvpn/keys/server.crt',
    'crl-verify' => '/etc/openvpn/crl.pem',
    'dev' => 'tun0',
    'dh' => '/etc/openvpn/keys/dh2048.pem',
    'group' => platform_family?('debian') ? 'nogroup' : 'nobody',
    'keepalive' => '10 120',
    'key' => '/etc/openvpn/keys/server.key',
    'log' => '/var/log/openvpn.log',
    'persist-key' => '',
    'persist-tun' => '',
    'port' => '1194',
    'proto' => 'udp',
    'script-security' => 2,
    'server' => '10.8.0.0 255.255.0.0',
    'up' => '/etc/openvpn/server.up.sh',
    'user' => 'nobody',
    'verb' => 1
  )
  push_routes [
    '192.168.10.0 255.255.255.0',
    '10.12.10.0 255.255.255.0',
  ]
  push_options(
    'dhcp-option' => [
      'DOMAIN local',
      'DOMAIN-SEARCH local',
    ]
  )
end

openvpn_user 'vpn_user' do
  config(
    'dev' => 'tun0',
    'port' => '1194',
    'proto' => 'udp'
  )
  gateway 'vpn.example.test'
  create_bundle false
  only_if { ::File.exist?('/etc/openvpn/keys/server.crt') }
end
