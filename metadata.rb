name              "openvpn"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures openvpn and includes rake tasks for managing certs"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.2"
depends           "logrotate"

recipe "openvpn", "Installs and configures openvpn"
recipe "openvpn::users", "Sets up openvpn cert/configs for users data bag items"

%w{ redhat centos fedora ubuntu debian }.each do |os|
  supports os
end

attribute "openvpn/local",
  :display_name => "OpenVPN Local",
  :description => "Local interface (ip) to listen on",
  :default => "ipaddress"

attribute "openvpn/proto",
  :display_name => "OpenVPN Protocol",
  :description => "UDP or TCP",
  :default => "udp"

attribute "openvpn/type",
  :display_name => "OpenVPN Type",
  :description => "Server or server-bridge",
  :default => "server"

attribute "openvpn/subnet",
  :display_name => "OpenVPN Subnet",
  :description => "Subnet to hand out to clients",
  :default => "10.8.0.0"

attribute "openvpn/netmask",
  :display_name => "OpenVPN Netmask",
  :description => "Netmask for clients",
  :default => "255.255.0.0"

attribute "openvpn/topology",
  :display_name => "VPN topology",
  :description => "Virtual addressing topology used by the VPN",
  :default => "subnet"

attribute "openvpn/tls_auth",
  :display_name => "TLS authentication key",
  :description => "The key to use for TLS authentication"

attribute "openvpn/tls_auth_direction",
  :display_name => "TLS authentication direction",
  :description => "Direction for TLS authentication",
  :default => "0"

attribute "openvpn/cipher",
  :display_name => "Cipher to use",
  :description => "Override the cipher to use for encryption on the VPN"

attribute "openvpn/client_config_dir",
  :display_name => "Directory for client configuration",
  :description => "Directory for client configuration"

attribute "openvpn/client_to_client",
  :display_name => "Allow client-to-client communication",
  :description => "Route communication between clients"
