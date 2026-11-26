# openvpn_client

Installs OpenVPN, writes a client configuration and enables and starts its service.
The caller supplies certificate and key files referenced by the configuration.

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

## Actions

* `:create` (default): install, configure, enable and start the client. Configuration changes restart it.
* `:delete`: stop and disable the client, then delete its configuration. Shared packages and
  caller-managed certificates remain installed.

## Properties

| Property | Type | Default |
| --- | --- | --- |
| `config_name` | String | Resource name |
| `config` | Hash | `client`, `dev tun`, `proto udp` directives |
| `config_path` | String | Platform-specific path below |
| `package_name` | String | `openvpn` |
| `install_epel` | Boolean | `true` |
| `cookbook` | String | `openvpn` |

On RHEL, Amazon Linux, Fedora and Arch, the client configuration is
`/etc/openvpn/client/<name>.conf` and the service is `openvpn-client@<name>`.
On Debian and Ubuntu, the configuration is `/etc/openvpn/<name>.conf` and the
service is `openvpn@<name>`. A custom path must remain compatible with the distribution unit.
