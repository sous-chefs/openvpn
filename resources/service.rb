# frozen_string_literal: true

provides :openvpn_service
unified_mode true

property :config_name, String, name_property: true
property :service_type, [String, nil]
property :service_name, [String, nil]
property :config_path, [String, nil]
property :supports, Hash, default: { status: true, restart: true }

action :enable do
  arch_git_config_link if platform_family?('arch')

  service resolved_service_name do
    supports new_resource.supports
    action :enable
  end
end

action :start do
  arch_git_config_link if platform_family?('arch')

  service resolved_service_name do
    supports new_resource.supports
    action :start
  end
end

action :restart do
  service resolved_service_name do
    supports new_resource.supports
    action :restart
  end
end

action :stop do
  service resolved_service_name do
    supports new_resource.supports
    action [:stop, :disable]
  end
end

action :delete do
  service resolved_service_name do
    supports new_resource.supports
    action [:stop, :disable]
  end
end

action_class do
  def resolved_service_type
    new_resource.service_type || new_resource.config_name
  end

  def resolved_config_path
    return new_resource.config_path if new_resource.config_path

    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora')
      "/etc/openvpn/#{new_resource.config_name}/#{new_resource.config_name}.conf"
    else
      "/etc/openvpn/#{new_resource.config_name}.conf"
    end
  end

  def resolved_service_name
    return new_resource.service_name if new_resource.service_name

    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora')
      "openvpn-#{resolved_service_type}@#{new_resource.config_name}.service"
    elsif platform_family?('debian', 'arch')
      "openvpn@#{new_resource.config_name}.service"
    else
      'openvpn'
    end
  end

  def arch_git_config_link
    link "/etc/openvpn/#{new_resource.config_name}/#{new_resource.config_name}.conf" do
      to resolved_config_path
      only_if { ::File.exist?(resolved_config_path) }
    end
  end
end
