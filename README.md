openvpn Cookbook
================
[![Build Status](https://secure.travis-ci.org/xhost-cookbooks/openvpn.png?branch=master)](http://travis-ci.org/xhost-cookbooks/openvpn)

Installs OpenVPN and sets up a fairly basic configuration. Since OpenVPN is very complex, we provide a baseline, but your site will need probably need to customize.


Requirements
------------
OpenSSL 0.9.7 or later and OpenSSL bindings for Ruby

### Platform
- Debian 6.0
- Ubuntu 10.04+
- RHEL 5.x and RHEL 6.x w/ EPEL enabled.

### Cookbooks
The `yum` cookbook by Opscode provides `recipe[yum::epel]` that can be used on RHEL-family systems to enable the EPEL repository containing the openvpn RPM. See __Usage__ below.

### Not Supported
This cookbook is designed to set up a basic installation of OpenVPN that will work for many common use cases. The following configurations are not supported by default with this cookbook:

- setting up routers and other network devices
- ethernet-bridging (tap interfaces)
- dual-factor authentication
- many other advanced OpenVPN configurations

For further modification of the cookbook see __Usage__ below.

For more information about OpenVPN, see the [official site](http://openvpn.net/).


Attributes
----------
These attributes are set by the cookbook by default.

* `node["openvpn"]["local"]` - IP to listen on, defaults to node[:ipaddress]
* `node["openvpn"]["proto"]` - Valid values are 'udp' or 'tcp', defaults to 'udp'.
* `node["openvpn"]["port"]` - Port to listen on, defaults to '1194'.
* `node["openvpn"]["type"]` - Valid values are 'server' or 'server-bridge'. Default is 'server' and it will create a routed IP tunnel, and use the 'tun' device. 'server-bridge' will create an ethernet bridge and requires a tap0 device bridged with the ethernet interface, and is beyond the scope of this cookbook.
* `node["openvpn"]["subnet"]` - Used for server mode to configure a VPN subnet to draw client addresses. Default is 10.8.0.0, which is what the sample OpenVPN config package uses.
* `node["openvpn"]["netmask"]` - Netmask for the subnet, default is 255.255.0.0.
* `node["openvpn"]["gateway"]` - FQDN for the VPN gateway server. Default is `node["fqdn"]`.
* `node["openvpn"]["log"]` - Server log file. Default /var/log/openvpn.log
* `node["openvpn"]["key_dir"]` - Location to store keys, certificates and related files. Default `/etc/openvpn/keys`.
* `node["openvpn"]["signing_ca_cert"]` - CA certificate for signing, default `/etc/openvpn/keys/ca.crt`
* `node["openvpn"]["signing_ca_key"]` - CA key for signing, default `/etc/openvpn/keys/ca.key`
* `node["openvpn"]["routes"]` - Array of routes to add as `push` statements in the server.conf. Default is empty.
* `node["openvpn"]["script_security"]` - Script Security setting to use in server config. Default is 1. The "up" script will not be included in the configuration if this is 0 or 1. Set it to 2 to use the "up" script.
* `node["openvpn"]["configure_default_server"]` - Boolean.  Set this to false if you want to create all of your "conf" files with the LWRP.
* `node["openvpn"]["push"]` - DEPRECATED: Use `routes` above. If you're still using this in your roles, the recipe will append to `routes` attribute.

The following attributes are used to populate the `easy-rsa` vars file. Defaults are the same as the vars file that ships with OpenVPN.

* `node["openvpn"]["key"]["ca_expire"]` - In how many days should the root CA key expire - `CA_EXPIRE`.
* `node["openvpn"]["key"]["expire"]` - In how many days should certificates expire - `KEY_EXPIRE`.
* `node["openvpn"]["key"]["size"]` - Default key size, set to 2048 if paranoid but will slow down TLS negotiation performance - `KEY_SIZE`.

The following are for the default values for fields place in the certificate from the vars file. Do not leave these blank.

* `node["openvpn"]["key"]["country"]` - `KEY_COUNTRY`
* `node["openvpn"]["key"]["province"]` - `KEY_PROVINCE`
* `node["openvpn"]["key"]["city"]` - `KEY_CITY`
* `node["openvpn"]["key"]["org"]` - `KEY_ORG`
* `node["openvpn"]["key"]["email"]` - `KEY_EMAIL`

Generate certificates for ldap group members (default disabled):
* `node["openvpn"]["ldap_users"]` - `false`
* `node["openvpn"]["ldap_group_name"]` - `nil`, for example `users`
* `node["openvpn"]["ldap_groups_dn"]` - `nil`, for example `ou=users,dc=example,dc=com`



Recipes
-------
### default
Sets up an OpenVPN server.

### users
Utilizes a data bag called `users` to generate OpenVPN keys for each user.


Usage
-----
Create a role for the OpenVPN server. See above for attributes that can be entered here.

```ruby
name "openvpn"
description "The server that runs OpenVPN"
run_list("recipe[openvpn]")
override_attributes(
  "openvpn" => {
    "gateway" => "vpn.example.com",
    "subnet" => "10.8.0.0",
    "netmask" => "255.255.0.0",
    "key" => {
      "country" => "US",
      "province" => "CA",
      "city" => "SanFrancisco",
      "org" => "Fort-Funston",
      "email" => "me@example.com"
    }
  }
)
```

**Note**: If you are using a Red Hat EL distribution, you may need the EPEL repository enabled to install the openvpn package. You can use Opscode's `recipe[yum::epel]` for this. Either add it to the run list in the openvpn role above, or add to a base role used by all your RHEL-family systems.

To push routes to clients, add `node['openvpn']['routes]` as an array attribute, e.g. if the internal network is 192.168.100.0/24:

```ruby
override_attributes(
  "openvpn" => {
    "routes => [
      "push 'route 192.168.100.0 255.255.255.0'"
    ]
  }
)
```

To automatically create new certificates and configurations for users, create data bags for each user. The only content required is the `id`, but this can be used in conjunction with other cookbooks by Opscode such as `users` or `samba`. See __SSL Certificates__ below for more about generating client certificate sets.

```javascript
{
  "id": "jtimberman"
}
```

This cookbook also provides an 'up' script that runs when OpenVPN is started. This script is for setting up firewall rules and kernel networking parameters as needed for your environment. Modify to suit your needs, upload the cookbook and re-run chef on the openvpn server. For example, you'll probably want to enable IP forwarding (sample Linux setting is commented out). The attribute `node["openvpn"]["script_security"]` must be set to 2 or higher to use this otherwise openvpn server startup will fail.


Customizing Server Configuration
--------------------------------
To further customize the server configuration, there are two templates that can be modified in this cookbook.

* templates/default/server.conf.erb
* templates/default/server.up.sh.erb

The first is the OpenVPN server configuration file. Modify to suit your needs for more advanced features of [OpenVPN](http://openvpn.net). The second is an `up` script run when OpenVPN starts. This is where you can add firewall rules, enable IP forwarding and other OS network settings required for OpenVPN. Attributes in the cookbook are provided as defaults, you can add more via the openvpn role if you need them.


Using the LWRP
--------------
To create (possibly multiple) "conf" files on a server, use openvpn_conf "name".  See the conf.rb file in the resources directory to find the supported attributes, or add some of your own.  If you don't want to use the default "server.conf" from the default recipe, set `node["openvpn"]["configure_default_server"]` to false, then use the LWRP to configure as many as you like.


SSL Certificates
----------------
Some of the easy-rsa tools are copied to /etc/openvpn/easy-rsa to provide the minimum to generate the certificates using the default and users recipes. We provide a Rakefile to make it easier to generate client certificate sets if you're not using the data bags above. To generate new client certificates you will need `rake` installed (either as a gem or a package), then run:

    cd /etc/openvpn/easy-rsa
    source ./vars
    rake client name="CLIENT_NAME" gateway="vpn.example.com"

Replace `CLIENT_NAME` and `vpn.example.com` with your desired values. The rake task will generate a tar.gz file with the configuration and certificates for the client.


SSL Certificates revoking
----------------
To revoke certificate 

    cd /etc/openvpn/easy-rsa
    source ./vars
    revoke-full <CLIENT_NAME>

Replace `<CLIENT_NAME>` with your desired values. The revoke-full script will modify index.txt openssl db file and create (update) `node["openvpn"]["key_dir"]/crl.pem` file, which is Certificate Revocation List. This file will be included in config file by default if it exists.

Re-run chef-client to apply the configuration in server config file.

Note the `error 23 at 0 depth lookup:certificate revoked` in the last line. That is what you want to see, as it indicates that a certificate verification of the revoked certificate failed and if crl.pem will be included in server.conf, then client's from this file cannot be connected to server.

Note client certificates usally valid prior to the expiration. Only the Certificate Revocation List can cause the server not to accept a client certificate.

Note The CRL file is not secret, and should be made world-readable so that the OpenVPN daemon can read it after root privileges have been dropped.

Recreating SSL Certificates
----------------
Remove one line of any appropriate certificate issued in the file `node["openvpn"]["key_dir"]/index.txt`.
Remove all files `<name>.*` from `node["openvpn"]["key_dir"]`
Re-run chef-client!

License & Authors
-----------------
- Author:: Joshua Timberman (<joshua@opscode.com>)

```text
Copyright:: 2009-2010, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
