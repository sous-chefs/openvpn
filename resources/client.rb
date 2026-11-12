# frozen_string_literal: true

provides :openvpn_client
unified_mode true

property :config_name, String, name_property: true
property :config, Hash, default: { 'client' => '', 'dev' => 'tun', 'proto' => 'udp' }
property :config_path, [String, nil]
property :package_name, String, default: 'openvpn'
property :install_epel, [true, false], default: true
property :cookbook, String, default: 'openvpn'

action :create do
  openvpn_install "client-#{new_resource.config_name}" do
    package_name new_resource.package_name
    install_epel new_resource.install_epel
  end

  openvpn_conf new_resource.config_name do
    config_path resolved_config_path
    config new_resource.config
    cookbook new_resource.cookbook
    notifies :restart, "openvpn_service[#{new_resource.config_name}]"
  end

  openvpn_service new_resource.config_name do
    config_path resolved_config_path
    service_type 'client'
    action [:enable, :start]
  end
end

action :delete do
  openvpn_service new_resource.config_name do
    service_type 'client'
    action :delete
  end

  openvpn_conf new_resource.config_name do
    config_path resolved_config_path
    action :delete
  end
end

action_class do
  def resolved_config_path
    return new_resource.config_path if new_resource.config_path

    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora', 'arch')
      "/etc/openvpn/client/#{new_resource.config_name}.conf"
    else
      "/etc/openvpn/#{new_resource.config_name}.conf"
    end
  end
end
