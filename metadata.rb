name              'openvpn'
version           '3.0.0'
maintainer        'Xhost Australia'
maintainer_email  'cookbooks@xhost.com.au'
license           'Apache 2.0'
description       'Installs and configures openvpn and includes rake tasks for managing certs.'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url        'https://github.com/xhost-cookbooks/openvpn'
issues_url        'https://github.com/xhost-cookbooks/openvpn/issues'

recipe 'openvpn::default',              'Installs OpenVPN only (no configuration).'
recipe 'openvpn::install',              'Installs OpenVPN only (no configuration).'
recipe 'openvpn::server',               'Installs and configures OpenVPN as a server.'
recipe 'openvpn::client',               'Installs and configures OpenVPN as a client.'
recipe 'openvpn::service',              'Manages the OpenVPN system service.'
recipe 'openvpn::users',                'Sets up openvpn cert/configs for users data bag items.'
recipe 'openvpn::enable_ip_forwarding', 'Enables IP forwarding on the system.'
recipe 'openvpn::install_bridge_utils', 'Installs bridge uitilies for Linux.'
recipe 'openvpn::easy_rsa',             'Installs easy-rsa.'

depends 'apt'
depends 'sysctl'
depends 'yum', '~> 3.0'
depends 'yum-epel'

supports 'arch'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

attribute 'openvpn/client_cn',
          display_name: 'OpenVPN Client CN',
          description:  "The client's Common Name used with the "\
                        'openvpn::client recipe (essentially a standalone recipe) '\
                        'for the client certificate and key.',
          default:      'client',
          recipes:      ['openvpn::client']

attribute 'openvpn/config/local',
          display_name: 'OpenVPN Local',
          description:  'Local interface (ip) to listen on',
          default:      nil,
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/config/proto',
          display_name: 'OpenVPN Protocol',
          description:  'The transport protocol to use for OpenVPN (UDP or TCP)',
          default:      'udp',
          choice:       %w(udp tcp),
          recipes:      ['openvpn::default', 'openvpn::server', 'openvpn::client']

attribute 'openvpn/type',
          display_name: 'OpenVPN Type',
          description:  'Server or server-bridge',
          default:      'server',
          choice:       ['server', 'server-bridge'],
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/subnet',
          display_name: 'OpenVPN Subnet',
          description:  'Subnet to hand out to clients',
          default:      '10.8.0.0',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/netmask',
          display_name: 'OpenVPN Netmask',
          description:  'Netmask for clients',
          default:      '255.255.0.0',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/config/port',
          display_name: 'OpenVPN Listen Port',
          description:  'Port to listen on, defaults to 1194',
          default:      '1194',
          choice:       %w(1194 443 80 1024),
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/gateway',
          display_name: 'OpenVPN Gateway FQDN',
          description:  'FQDN for the VPN gateway server. Default is vpn.domain',
          recipes:      ['openvpn::default', 'openvpn::client']

attribute 'openvpn/config/log',
          display_name: 'OpenVPN Log File',
          description:  'OpenVPN Server log file. Default /var/log/openvpn.log',
          default:      '/var/log/openvpn.log',
          recipes:      ['openvpn::default', 'openvpn::server', 'openvpn::client']

attribute 'openvpn/key_dir',
          display_name: 'OpenVPN Key Directory',
          description:  'Location to store keys, certificates and related files. '\
                        'Default: /etc/openvpn/keys',
          default:      '/etc/openvpn/keys',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/signing_ca_cert',
          display_name: 'OpenVPN CA Certificate',
          description:  'CA certificate for signing, default /etc/openvpn/keys/ca.crt',
          default:      '/etc/openvpn/keys/ca.crt',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/signing_ca_key',
          display_name: 'OpenVPN CA key',
          description:  'CA key for signing, default /etc/openvpn/keys/ca.key',
          default:      '/etc/openvpn/keys/ca.key',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/push_options',
          display_name: 'OpenVPN Push DHCP Options',
          description:  'An array of DHCP options to push to clients from the server.conf. '\
                        'Default is empty.',
          type:         'array',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/push_routes',
          display_name: 'OpenVPN Push Routes',
          description:  'An array of routes to push to clients from the server.conf. '\
                        'Default is empty.',
          type:         'array',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/script_security',
          display_name: 'OpenVPN Script Security',
          description:  'Script Security setting to use in server config. '\
                        'Default is 1. The "up" script will not be included if this is 0 or 1. '\
                        'Set it to 2 to use the "up" script',
          default:      '1',
          recipes:      ['openvpn::default', 'openvpn::server']

attribute 'openvpn/configure_default_server',
          display_name: 'Configure Default Server',
          description:  'Boolean to determine whether the default recipe will create a "conf" '\
                        'file for the default server. Set to false if you want to use only the '\
                        'LWRP to create the conf files.',
          default:      'true',
          recipes:      ['openvpn::default', 'openvpn::server', 'openvpn::client']

attribute 'openvpn/key/ca_expire',
          display_name: 'OpenVPN Root CA Expiry',
          description:  'In how many days should the root CA key expire',
          default:      '3650',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/expire',
          display_name: 'OpenVPN Certificate Expiry',
          description:  'In how many days should certificates expire',
          default:      '3650',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/size',
          display_name: 'OpenVPN Key Size',
          description:  'Default key size, set to 2048 if paranoid but will slow down '\
                        'TLS negotiation performance',
          default:      '1024',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/country',
          display_name: 'OpenVPN Certificate Country',
          description:  'The country for the TLS certificate',
          default:      'US',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/province',
          display_name: 'OpenVPN Certificate Province',
          description:  'The province for the TLS certificate',
          default:      'CA',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/city',
          display_name: 'OpenVPN Certificate City',
          description:  'The city for the TLS certificate',
          default:      'San Francisco',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/org',
          display_name: 'OpenVPN Certificate Organization',
          description:  'The organization name for the TLS certificate',
          default:      'Fort-Funston',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/email',
          display_name: 'OpenVPN Certificate Email',
          description:  'The email address for the TLS certificate',
          default:      'me@example.com',
          recipes:      ['openvpn::default', 'openvpn::users', 'openvpn::server']

attribute 'openvpn/key/message_digest',
          display_name: 'OpenVPN Message Digest',
          description:  'The message digest used for generating certificates by OpenVPN',
          default:      'sha256',
          choice:       %w(sha256 sha1),
          recipes:      ['openvpn::default', 'openvpn::server']
