# OpenVPN 8 Migration

OpenVPN 8 is a full custom resource migration. The cookbook no longer ships public recipes or
node attributes.

## What Changed

* `recipes/` was removed. Use resources from a wrapper or policy cookbook instead.
* `attributes/` was removed. Pass values directly to resource properties.
* Berkshelf was replaced by `Policyfile.rb` for local test dependency resolution.
* EOL platform releases were removed; Arch Linux and Red Hat support remain available.

## Recipe Replacement

### `openvpn::default` or `openvpn::install`

```ruby
openvpn_install 'default'
```

### `openvpn::server`

```ruby
openvpn_server 'server' do
  config(
    'dev' => 'tun0',
    'port' => '1194',
    'proto' => 'udp',
    'server' => '10.8.0.0 255.255.0.0'
  )
end
```

### `openvpn::client`

```ruby
openvpn_client 'office' do
  config(
    'client' => '',
    'dev' => 'tun',
    'proto' => 'udp',
    'remote' => 'vpn.example.test 1194',
    'ca' => '/etc/openvpn/office/ca.crt',
    'cert' => '/etc/openvpn/office/client.crt',
    'key' => '/etc/openvpn/office/client.key'
  )
end
```

Supply certificate files separately. `openvpn_client` manages the installed client;
`openvpn_user` generates credentials and bundles for distribution to clients.

### `openvpn::users`

```ruby
openvpn_user 'alice' do
  gateway 'vpn.example.com'
  config(
    'dev' => 'tun0',
    'port' => '1194',
    'proto' => 'udp'
  )
end
```

## Resource Overview

* `openvpn_install` installs OpenVPN packages.
* `openvpn_client` configures and runs a client instance.
* `openvpn_conf` renders an OpenVPN configuration file.
* `openvpn_server` builds the baseline server, PKI files, configuration, and service.
* `openvpn_service` manages the OpenVPN systemd service.
* `openvpn_user` creates client certificates and configuration bundles.

See the files in `documentation/` for full property and action details.
