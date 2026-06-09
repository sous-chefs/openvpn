# openvpn_conf

Manages OpenVPN configuration files. Renders a config file from a template with the provided options, routes, and push options.

## Actions

| Action    | Description                              |
|-----------|------------------------------------------|
| `:create` | Creates the configuration file (default) |
| `:delete` | Removes the configuration file           |

## Properties

| Property            | Type        | Default             | Description                               |
|---------------------|-------------|---------------------|-------------------------------------------|
| `config`            | Hash        | `{}`                | Hash of OpenVPN config directives         |
| `template_source`   | String      | `'server.conf.erb'` | Template source file                      |
| `template_cookbook` | String      | `'openvpn'`         | Cookbook containing the template          |
| `push_routes`       | Array       | `[]`                | Routes to push to clients                 |
| `push_options`      | Hash, Array | `{}`                | Additional options to push to clients     |
| `conf_dir`          | String      | platform-dependent  | Directory for the config file (see notes) |

### Platform Notes

- **RHEL/Fedora**: `conf_dir` defaults to `/etc/openvpn/<name>` (per-instance directory)
- **Debian/Ubuntu**: `conf_dir` defaults to `/etc/openvpn`

## Examples

### Basic server configuration

```ruby
openvpn_conf 'server' do
  config(
    'port' => '1194',
    'proto' => 'udp',
    'dev' => 'tun0',
    'server' => '10.8.0.0 255.255.0.0',
    'ca' => '/etc/openvpn/keys/ca.crt',
    'cert' => '/etc/openvpn/keys/server.crt',
    'key' => '/etc/openvpn/keys/server.key',
    'dh' => '/etc/openvpn/keys/dh2048.pem'
  )
  push_routes ['10.0.0.0 255.255.255.0']
end
```

### With push options

```ruby
openvpn_conf 'server' do
  config(
    'port' => '1194',
    'proto' => 'udp',
    'dev' => 'tun0'
  )
  push_options(
    'dhcp-option' => ['DNS 8.8.8.8', 'DOMAIN example.com']
  )
end
```

### Client configuration

```ruby
openvpn_conf 'myvpn' do
  config(
    'client' => '',
    'dev' => 'tun',
    'proto' => 'tcp',
    'remote' => '1.2.3.4 443'
  )
end
```
