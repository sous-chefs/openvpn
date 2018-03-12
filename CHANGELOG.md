# openvpn Cookbook CHANGELOG

This file is used to list changes made in each version of the openvpn cookbook.

## v3.0.0

- [Chef-13 compatibility](https://github.com/sous-chefs/openvpn/issues/102)
- [Use local delivery for testing](https://github.com/sous-chefs/openvpn/issues/83)
- [Fix file existence check](https://github.com/sous-chefs/openvpn/pull/112)
- [Fix port attribute in Rakefile](https://github.com/sous-chefs/openvpn/pull/107)
- [Archlinux openvpn-git support](https://github.com/sous-chefs/openvpn/issues/97)
- [Lazy evaluation for key generation](https://github.com/sous-chefs/openvpn/issues/100)
- [User configuration template can now be set to a user defined template](https://github.com/sous-chefs/openvpn/pull/95)
- [Allow Override of global push settings](https://github.com/sous-chefs/openvpn/pull/94)
- [Fix Debian 8 service](https://github.com/sous-chefs/openvpn/pull/92)
- [Fix Fedora service](https://github.com/sous-chefs/openvpn/pull/91)
- [EasyRSA recipe added](https://github.com/sous-chefs/openvpn/issues/90)
- [Added ability to name configuration import file](https://github.com/sous-chefs/openvpn/pull/86)
- [Generate CRL](https://github.com/sous-chefs/openvpn/pull/82)
- [Don't set username in configuration template](https://github.com/sous-chefs/openvpn/issues/75)
- [Enable 'up' script in server config](https://github.com/sous-chefs/openvpn/pull/74)
- [Fix OpenVPN startup on Centos-7](https://github.com/sous-chefs/openvpn/issues/73)
- [Enable Message digest configuration](https://github.com/sous-chefs/openvpn/pull/69)
- [Install bridge utils when using server-bridge](https://github.com/sous-chefs/openvpn/issues/59)
- [Add a method to configure and enable `ip_forwarding`](https://github.com/sous-chefs/openvpn/issues/60)

## v2.1.0

Updating to use cookbook yum ~> 3.0 Fixing up style issues Updating testing bits

## v2.0.4

fixing metadata version error. locking to 3.0

## v2.0.2

Locking yum dependency to '< 3'

## v2.0.0

- [COOK-3691] Creating and using a openvpn_conf LWRP

## v1.1.4

### Bug

- **[COOK-3317](https://tickets.chef.io/browse/COOK-3317)** - Fix and make `server.up.sh` useful and customizable

### New Feature

- **[COOK-3315](https://tickets.chef.io/browse/COOK-3315)** - Remove hardcoded variables in configuration file

## v1.1.2

### Improvement

- **[COOK-2820](https://tickets.chef.io/browse/COOK-2820)** - Update metadata.rb for all attributes and recipes

## v1.1.0

- [COOK-1231] - dont use up script if security isnt >1
- [COOK-2513] Changed user and group to attributes

## v1.0.2

- [COOK-2288] - make attribute assignment in openvpn::default compatible w/ Chef 11

## v1.0.0

- [COOK-1171] - use proper key size
- [COOK-1231] - add script_security attribute

## v0.99.2

- [COOK-564] - fix users recipe search, add port attribute
- [COOK-621] - rename attribute "push" to "routes" - see below.
