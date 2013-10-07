openvpn Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the openvpn cookbook.


v1.1.4
------
### Improvement
- Ability to add unspecified options to the server config, made verb and mute values configurable

v1.1.2
------
### Improvement
- **[COOK-2820](https://tickets.opscode.com/browse/COOK-2820)** - Update metadata.rb for all attributes and recipes

v1.1.0
------
- [COOK-1231] - dont use up script if security isnt >1
- [COOK-2513] Changed user and group to attributes

v1.0.2
------
- [COOK-2288] - make attribute assignment in openvpn::default compatible w/ Chef 11

v1.0.0
------
- [COOK-1171] - use proper key size
- [COOK-1231] - add script_security attribute

v0.99.2
-------
- [COOK-564] - fix users recipe search, add port attribute
- [COOK-621] - rename attribute "push" to "routes" - see below.
