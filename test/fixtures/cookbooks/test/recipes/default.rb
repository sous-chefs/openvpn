execute 'apt-get update' if platform_family?('debian')

include_recipe 'yum-epel' if platform_family?('rhel')
include_recipe 'openvpn'
