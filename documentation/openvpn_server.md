# openvpn_server

Sets up the OpenVPN PKI infrastructure including CA certificates, server keys, DH parameters, easy-rsa tools, and certificate revocation list (CRL).

## Actions

| Action    | Description                              |
|-----------|------------------------------------------|
| `:create` | Creates the PKI infrastructure (default) |

## Properties

Properties from the `_pki` partial (shared with `openvpn_user`):

| Property       | Type    | Default                   | Description                  |
|----------------|---------|---------------------------|------------------------------|
| `key_dir`      | String  | `'/etc/openvpn/keys'`     | Directory to store PKI files |
| `easy_rsa_dir` | String  | `'/etc/openvpn/easy-rsa'` | Easy-RSA tools directory     |
| `key_size`     | Integer | `2048`                    | RSA key size in bits         |
| `ca_expire`    | Integer | `3650`                    | CA certificate expiry (days) |
| `key_expire`   | Integer | `3650`                    | Key expiry (days)            |
| `key_country`  | String  | `'US'`                    | Certificate country          |
| `key_province` | String  | `'CA'`                    | Certificate state/province   |
| `key_city`     | String  | `'San Francisco'`         | Certificate city             |
| `key_org`      | String  | `'Fort Funston'`          | Certificate organization     |
| `key_email`    | String  | `'admin@example.com'`     | Certificate email            |

Server-specific properties:

| Property           | Type    | Default         | Description                            |
|--------------------|---------|-----------------|----------------------------------------|
| `crl_expire`       | Integer | `30`            | CRL expiry (days)                      |
| `message_digest`   | String  | `'sha256'`      | Message digest algorithm               |
| `subnet`           | String  | `'10.8.0.0'`    | VPN subnet for server.up.sh            |
| `netmask`          | String  | `'255.255.0.0'` | VPN netmask for server.up.sh           |
| `server_up_script` | Boolean | `true`          | Deploy the server.up.sh startup script |

## Examples

### Basic usage

```ruby
openvpn_server 'default'
```

### Custom PKI settings

```ruby
openvpn_server 'default' do
  key_org 'My Company'
  key_email 'vpn@example.com'
  key_country 'GB'
  key_province 'London'
  key_city 'London'
  key_size 4096
end
```

### Without server up script

```ruby
openvpn_server 'default' do
  server_up_script false
end
```
