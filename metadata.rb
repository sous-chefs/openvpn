name              'openvpn'
version           '3.0.0'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Installs and configures openvpn and includes rake tasks for managing certs.'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url        'https://github.com/sous-chefs/openvpn'
issues_url        'https://github.com/sous-chefs/openvpn/issues'
chef_version      '>= 12.9' if respond_to?(:chef_version)

supports 'arch'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

# TODO: rm after chef_version '>= 14.0'
depends 'sysctl', '>= 1.0'
depends 'yum-epel'
