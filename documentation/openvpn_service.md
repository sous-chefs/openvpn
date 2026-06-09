# openvpn_service

Manages the OpenVPN systemd service. Handles platform-specific service naming conventions for Debian and RHEL family systems.

## Actions

| Action    | Description                                      |
|-----------|--------------------------------------------------|
| `:create` | Enables and starts the OpenVPN service (default) |
| `:delete` | Stops and disables the OpenVPN service           |

## Properties

| Property        | Type   | Default    | Description                                |
|-----------------|--------|------------|--------------------------------------------|
| `instance_name` | String | name       | Instance name (name property)              |
| `vpn_type`      | String | `'server'` | VPN type, must be `'server'` or `'client'` |

### Platform Notes

- **Debian/Ubuntu**: Uses `openvpn@<vpn_type>.service`
- **RHEL/Fedora (8+)**: Uses `openvpn-<vpn_type>@<vpn_type>.service` with a systemd symlink
- **Other**: Uses the generic `openvpn` service name

## Examples

### Basic server service

```ruby
openvpn_service 'default' do
  vpn_type 'server'
end
```

### Client service

```ruby
openvpn_service 'default' do
  vpn_type 'client'
end
```

### Remove service

```ruby
openvpn_service 'default' do
  action :delete
end
```
