# openvpn Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/openvpn.svg)](https://supermarket.chef.io/cookbooks/openvpn)
[![CI State](https://github.com/sous-chefs/openvpn/workflows/ci/badge.svg)](https://github.com/sous-chefs/openvpn/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Provides custom resources for installing and configuring OpenVPN Community Edition.

## Requirements

### Platforms

* AlmaLinux 8+
* Amazon Linux 2023+
* CentOS Stream 9+
* Debian 12+
* Fedora
* Oracle Linux 8+
* Rocky Linux 8+
* Ubuntu 22.04+

### Chef

Chef Infra Client 15.3 or later.

## Resources

* [openvpn_conf](documentation/openvpn_conf.md)
* [openvpn_install](documentation/openvpn_install.md)
* [openvpn_server](documentation/openvpn_server.md)
* [openvpn_service](documentation/openvpn_service.md)
* [openvpn_user](documentation/openvpn_user.md)

## Usage

Install OpenVPN only:

```ruby
openvpn_install 'default'
```

Create a baseline server:

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

Create a client bundle:

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

## Migration

This cookbook no longer provides public recipes or attributes. See [migration.md](migration.md)
for the OpenVPN 8 migration guide.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook
maintainers working together to maintain important cookbooks. If you would like to know more,
visit [sous-chefs.org](https://sous-chefs.org/) or chat with us on the Chef Community Slack in
[#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Contributors

This project exists thanks to all the people who contribute.
