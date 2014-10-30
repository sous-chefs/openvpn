name              'openvpn'
maintainer        'Xhost Australia'
maintainer_email  'cookbooks@xhost.com.au'
license           'Apache 2.0'
description       'Installs and configures openvpn and includes rake tasks for managing certs.'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '2.1.1'

recipe 'openvpn',         'Installs and configures OpenVPN.'
recipe 'openvpn::users',  'Sets up openvpn cert/configs for users data bag items.'

depends 'yum', '~> 3.0'
depends 'yum-epel'

supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

attribute 'openvpn/type',
          display_name: 'OpenVPN Type',
          description:  'Server or server-bridge',
          default:      'server',
          recipes:      ['openvpn']

attribute 'openvpn/subnet',
          display_name: 'OpenVPN Subnet',
          description:  'Subnet to hand out to clients',
          default:      '10.8.0.0',
          recipes:      ['openvpn']

attribute 'openvpn/netmask',
          display_name: 'OpenVPN Netmask',
          description:  'Netmask for clients',
          default:      '255.255.0.0',
          recipes:      ['openvpn']

attribute 'openvpn/gateway',
          display_name: 'OpenVPN Gateway FQDN',
          description:  'FQDN for the VPN gateway server. Default is vpn.domain',
          recipes:      ['openvpn']

attribute 'openvpn/key_dir',
          display_name: 'OpenVPN Key Directory',
          description:  'Location to store keys, certificates and related files. '\
                        'Default: /etc/openvpn/keys',
          default:      '/etc/openvpn/keys',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/signing_ca_cert',
          display_name: 'OpenVPN CA Certificate',
          description:  'CA certificate for signing, default /etc/openvpn/keys/ca.crt',
          default:      '/etc/openvpn/keys/ca.crt',
          recipes:      ['openvpn']

attribute 'openvpn/signing_ca_key',
          display_name: 'OpenVPN CA key',
          description:  'CA key for signing, default /etc/openvpn/keys/ca.key',
          default:      '/etc/openvpn/keys/ca.key',
          recipes:      ['openvpn']

attribute 'openvpn/configure_default_server',
          display_name: 'Configure Default Server',
          description:  'Boolean to determine whether the default recipe will create a "conf" '\
                        'file for the default server. Set to false if you want to use the LWRP to '\
                        'create the conf files.',
          default:      'true',
          recipes:      ['openvpn']

attribute 'openvpn/configure_default_server',
          display_name: 'Configure Default Server',
          description:  'Boolean to determine whether the default recipe will create a "conf" '\
                        'file for the default server. Set to false if you want to use only the '\
                        'LWRP to create the conf files.',
          default:      'true',
          recipes:      ['openvpn::default']

attribute 'openvpn/config/local',
          display_name: 'OpenVPN Local',
          description:  'Local interface (ip) to listen on',
          default:      'ipaddress',
          recipes:      ['openvpn']

attribute 'openvpn/config/log',
          display_name: 'OpenVPN Log File',
          description:  'OpenVPN Server log file. Default /var/log/openvpn.log',
          default:      '/var/log/openvpn.log',
          recipes:      ['openvpn']

attribute 'openvpn/config/proto',
          display_name: 'OpenVPN Protocol',
          description:  'UDP or TCP',
          default:      'udp',
          recipes:      ['openvpn']

attribute 'openvpn/config/port',
          display_name: 'OpenVPN Listen Port',
          description:  'Port to listen on, defaults to 1194',
          default:      '1194',
          recipes:      ['openvpn']

attribute 'openvpn/config/script-security',
          display_name: 'OpenVPN Script Security',
          description:  'Script Security setting to use in server config. '\
                        'Default is 1. The "up" script will not be included if this is 0 or 1. '\
                        'Set it to 2 to use the "up" script',
          default:      '1',
          recipes:      ['openvpn']

attribute 'openvpn/config/routes',
          display_name: 'OpenVPN Routes',
          description:  'Array of routes to add as push statements in the server.conf. '\
                        'Default is empty.',
          type:         'array',
          recipes:      ['openvpn']

attribute 'openvpn/key/ca_expire',
          display_name: 'OpenVPN Root CA Expiry',
          description:  'In how many days should the root CA key expire',
          default:      '3650',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/expire',
          display_name: 'OpenVPN Certificate Expiry',
          description:  'In how many days should certificates expire',
          default:      '3650',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/size',
          display_name: 'OpenVPN Key Size',
          description:  'Default key size, set to 2048 if paranoid but will slow down '\
                        'TLS negotiation performance',
          default:      '1024',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/country',
          display_name: 'OpenVPN Certificate Country',
          description:  'The country for the TLS certificate',
          default:      'US',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/province',
          display_name: 'OpenVPN Certificate Province',
          description:  'The province for the TLS certificate',
          default:      'CA',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/city',
          display_name: 'OpenVPN Certificate City',
          description:  'The city for the TLS certificate',
          default:      'San Francisco',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/org',
          display_name: 'OpenVPN Certificate Organization',
          description:  'The organization name for the TLS certificate',
          default:      'Fort-Funston',
          recipes:      ['openvpn', 'openvpn::users']

attribute 'openvpn/key/email',
          display_name: 'OpenVPN Certificate Email',
          description:  'The email address for the TLS certificate',
          default:      'me@example.com',
          recipes:      ['openvpn', 'openvpn::users']
