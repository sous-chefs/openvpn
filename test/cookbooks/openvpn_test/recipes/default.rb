configuration = {
  'client' => nil,
  'dev' => 'tun',
  'proto' => 'udp',
  'remote' => '127.0.0.1 1194',
  'resolv-retry' => 'infinite',
  'nobind' => nil,
  'persist-key' => nil,
  'persist-tun' => nil,
  'ca' => 'ca.crt',
  'cert' => 'cert.crt',
  'key' =>  'username.key',
  'comp-lzo' => nil,
  'verb' => 3
}

openvpn_client "openvpn_test" do
  conf configuration
end
