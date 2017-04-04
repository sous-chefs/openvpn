apt_update 'update'

include_recipe 'yum-epel' if platform_family?('rhel')
include_recipe 'openvpn'
