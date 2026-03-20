# openvpn_user

Generates OpenVPN client certificates, configuration files, and optional tar.gz bundles for VPN users.

## Actions

| Action    | Description                                       |
|-----------|---------------------------------------------------|
| `:create` | Generates client certificate and bundle (default) |
| `:delete` | Removes client configuration files and bundle     |

## Properties

Properties from the `_pki` partial (shared with `openvpn_server`):

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

User-specific properties:

| Property            | Type    | Default      | Description                                   |
|---------------------|---------|--------------|-----------------------------------------------|
| `client_name`       | String  | name         | Client name (name property)                   |
| `create_bundle`     | Boolean | `true`       | Create a tar.gz bundle with certs and configs |
| `force`             | Boolean | `false`      | Force regeneration of existing certificates   |
| `destination`       | String  | `key_dir`    | Output directory for bundle and configs       |
| `additional_vars`   | Hash    | `{}`         | Extra template variables for inline configs   |
| `compression`       | String  | `nil`        | Compression setting for client config         |
| `client_prefix`     | String  | `'vpn-prod'` | Prefix for client config filenames            |
| `template_cookbook` | String  | `'openvpn'`  | Cookbook containing client config templates   |

## Examples

### Basic user with bundle

```ruby
openvpn_user 'jsmith'
```

### User with inline config (no bundle)

```ruby
openvpn_user 'jsmith' do
  create_bundle false
end
```

### Custom prefix and destination

```ruby
openvpn_user 'jsmith' do
  client_prefix 'vpn-staging'
  destination '/tmp/vpn-configs'
end
```

### Force certificate regeneration

```ruby
openvpn_user 'jsmith' do
  force true
end
```

### Remove a user

```ruby
openvpn_user 'jsmith' do
  action :delete
end
```
