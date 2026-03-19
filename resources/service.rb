# frozen_string_literal: true

provides :openvpn_service
unified_mode true

default_action :create

property :instance_name, String, name_property: true
property :vpn_type, String, default: 'server', equal_to: %w(server client)

action :create do
  service_name = if platform_family?('debian')
                   "openvpn@#{new_resource.vpn_type}.service"
                 elsif platform_family?('rhel', 'fedora')
                   "openvpn-#{new_resource.vpn_type}@#{new_resource.vpn_type}.service"
                 else
                   'openvpn'
                 end

  # RHEL/Fedora need a symlink for the instance service
  if platform_family?('rhel', 'fedora')
    link "/etc/systemd/system/multi-user.target.wants/#{service_name}" do
      to '/usr/lib/systemd/system/openvpn@.service'
      not_if { ::File.exist?("/etc/systemd/system/multi-user.target.wants/#{service_name}") }
    end
  end

  service 'openvpn' do
    service_name service_name
    action [:enable, :start]
  end
end

action :delete do
  service 'openvpn' do
    action [:stop, :disable]
  end
end
