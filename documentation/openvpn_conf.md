# openvpn_conf

Renders an OpenVPN configuration file.

## Actions

| Action    | Description                         |
|-----------|-------------------------------------|
| `:create` | Creates the config file (default)   |
| `:delete` | Deletes the config file             |

## Properties

| Property          | Type   | Default                     | Description                         |
|-------------------|--------|-----------------------------|-------------------------------------|
| `config_name`     | String | name property               | OpenVPN instance/config name        |
| `config_path`     | String | platform-specific           | Destination config path             |
| `cookbook`        | String | `'openvpn'`                 | Template cookbook                   |
| `config`          | Hash   | `{}`                        | OpenVPN directives                  |
| `template_source` | String | `'server.conf.erb'`         | Template source                     |
| `push_routes`     | Array  | `[]`                        | Routes rendered as push directives  |
| `push_options`    | Hash   | `{}`                        | Additional push options             |
| `client_cn`       | String | `'client'`                  | Client common name                  |

## Examples

```ruby
openvpn_conf 'server' do
  config(
    'dev' => 'tun0',
    'port' => '1194',
    'proto' => 'udp',
    'server' => '10.8.0.0 255.255.0.0'
  )
  push_routes ['192.168.10.0 255.255.255.0']
  push_options('dhcp-option' => ['DOMAIN local'])
end
```
