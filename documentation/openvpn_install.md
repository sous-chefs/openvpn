# openvpn_install

Installs the OpenVPN package and optionally configures IP forwarding and package repositories.

## Actions

| Action    | Description                         |
|-----------|-------------------------------------|
| `:create` | Installs OpenVPN packages (default) |
| `:delete` | Removes OpenVPN packages            |

## Properties

| Property               | Type    | Default                      | Description                                     |
|------------------------|---------|------------------------------|-------------------------------------------------|
| `packages`             | Array   | `['openvpn']`                | List of packages to install                     |
| `enable_ip_forwarding` | Boolean | `true`                       | Enable IPv4/IPv6 forwarding via sysctl          |
| `use_apt_repo`         | Boolean | `true` on Debian family      | Add the official OpenVPN APT repository         |
| `use_epel`             | Boolean | `true` on RHEL/Amazon family | Include the yum-epel recipe for EPEL repository |

## Examples

### Basic usage

```ruby
openvpn_install 'default'
```

### Without IP forwarding

```ruby
openvpn_install 'default' do
  enable_ip_forwarding false
end
```

### Without the official APT repository

```ruby
openvpn_install 'default' do
  use_apt_repo false
end
```
