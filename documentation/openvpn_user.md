# openvpn_user

Creates OpenVPN client certificates and configuration files.

## Actions

| Action    | Description                         |
|-----------|-------------------------------------|
| `:create` | Creates client files (default)      |
| `:delete` | Deletes generated client files      |

## Properties

| Property              | Type        | Default                    | Description                         |
|-----------------------|-------------|----------------------------|-------------------------------------|
| `client_name`         | String      | name property              | Client certificate common name      |
| `create_bundle`       | true, false | `true`                     | Create tar bundle plus config files |
| `force`               | true, false | `nil`                      | Regenerate files even if present    |
| `destination`         | String      | `key_dir`                  | Destination directory               |
| `key_vars`            | Hash        | `{}`                       | Certificate environment overrides   |
| `additional_vars`     | Hash        | `{}`                       | Extra inline template variables     |
| `key_dir`             | String      | `'/etc/openvpn/keys'`      | PKI directory                       |
| `easy_rsa_dir`        | String      | `'/etc/openvpn/easy-rsa'`  | easy-rsa helper directory           |
| `client_prefix`       | String      | `'vpn-prod'`               | Client config filename prefix       |
| `cookbook`            | String      | `'openvpn'`                | Template cookbook                   |
| `config`              | Hash        | `{}`                       | Client config defaults              |
| `gateway`             | String      | node FQDN                  | VPN gateway hostname                |
| `server_verification` | String, nil | `nil`                      | Server verification directive       |

## Examples

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

```ruby
openvpn_user 'bob' do
  create_bundle false
  gateway 'vpn.example.com'
end
```
