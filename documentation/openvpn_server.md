# openvpn_server

Installs OpenVPN, prepares PKI files, renders server configuration, and manages the service.

## Actions

| Action    | Description                             |
|-----------|-----------------------------------------|
| `:create` | Creates the server baseline (default)   |
| `:delete` | Removes config/service-managed artifacts |

## Properties

| Property                | Type        | Default                    | Description                         |
|-------------------------|-------------|----------------------------|-------------------------------------|
| `config_name`           | String      | name property              | OpenVPN instance/config name        |
| `package_name`          | String      | `'openvpn'`                | OpenVPN package name                |
| `install_epel`          | true, false | `true`                     | Install EPEL on EL nodes            |
| `key_dir`               | String      | `'/etc/openvpn/keys'`      | PKI directory                       |
| `easy_rsa_dir`          | String      | `'/etc/openvpn/easy-rsa'`  | easy-rsa helper directory           |
| `config_path`           | String      | platform-specific          | Server config path                  |
| `up_script_path`        | String      | `'/etc/openvpn/server.up.sh'` | Startup script path              |
| `up_script_dir`         | String      | `'/etc/openvpn/server.up.d'` | Startup script directory          |
| `crl_path`              | String      | `'/etc/openvpn/crl.pem'`   | Public CRL copy path                |
| `subnet`                | String      | `'10.8.0.0'`               | VPN subnet                          |
| `netmask`               | String      | `'255.255.0.0'`            | VPN netmask                         |
| `config`                | Hash        | generated defaults         | OpenVPN config directives           |
| `push_routes`           | Array       | `[]`                       | Client route pushes                 |
| `push_options`          | Hash        | `{}`                       | Client option pushes                |
| `key_size`              | Integer     | `2048`                     | RSA/DH key size                     |
| `ca_expire`             | Integer     | `3650`                     | CA validity in days                 |
| `key_expire`            | Integer     | `3650`                     | Certificate validity in days        |
| `crl_expire`            | Integer     | `30`                       | CRL validity in days                |
| `key_country`           | String      | `'US'`                     | Certificate country                 |
| `key_province`          | String      | `'CA'`                     | Certificate province                |
| `key_city`              | String      | `'San Francisco'`          | Certificate city                    |
| `key_org`               | String      | `'Fort Funston'`           | Certificate organization            |
| `key_email`             | String      | `'admin@foobar.com'`       | Certificate email                   |
| `message_digest`        | String      | `'sha256'`                 | OpenSSL message digest              |
| `configure`             | true, false | `true`                     | Render server config                |
| `enable_ip_forwarding`  | true, false | `true`                     | Enable IPv4/IPv6 forwarding         |
| `install_bridge_utils`  | true, false | `false`                    | Install bridge utilities            |
| `cookbook`              | String      | `'openvpn'`                | Template cookbook                   |

## Examples

```ruby
openvpn_server 'server' do
  config(
    'dev' => 'tun0',
    'port' => '1194',
    'proto' => 'udp',
    'server' => '10.8.0.0 255.255.0.0'
  )
  push_routes ['192.168.10.0 255.255.255.0']
end
```
