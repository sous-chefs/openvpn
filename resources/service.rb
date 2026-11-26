# frozen_string_literal: true

provides :openvpn_service
unified_mode true

property :config_name, String, name_property: true
property :service_type, [String, nil]
property :service_name, [String, nil]
property :config_path, [String, nil]
property :supports, Hash, default: { status: true, restart: true }

action :enable do
  link_package_config
  service resolved_service_name do
    supports new_resource.supports
    action :enable
  end
end

action :start do
  link_package_config
  service resolved_service_name do
    supports new_resource.supports
    action :start
  end
end

action :restart do
  link_package_config
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

  if custom_package_config? && package_config_link?
    link package_config_path do
      action :delete
    end
  end
end

action_class do
  def resolved_service_type
    new_resource.service_type || new_resource.config_name
  end

  def package_config_path
    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora', 'arch')
      "/etc/openvpn/#{resolved_service_type}/#{new_resource.config_name}.conf"
    else
      "/etc/openvpn/#{new_resource.config_name}.conf"
    end
  end

  def custom_package_config?
    new_resource.config_path && !new_resource.service_name &&
      ::File.expand_path(new_resource.config_path) != package_config_path
  end

  def package_config_link?
    ::File.symlink?(package_config_path) &&
      ::File.expand_path(::File.readlink(package_config_path), ::File.dirname(package_config_path)) == ::File.expand_path(new_resource.config_path)
  end

  def link_package_config
    return unless custom_package_config?
    return if package_config_link?

    if ::File.exist?(package_config_path) || ::File.symlink?(package_config_path)
      raise Chef::Exceptions::ValidationFailed, "OpenVPN package configuration already exists at #{package_config_path}"
    end

    link package_config_path do
      to ::File.expand_path(new_resource.config_path)
    end
  end

  def resolved_service_name
    return new_resource.service_name if new_resource.service_name

    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora', 'arch')
      "openvpn-#{resolved_service_type}@#{new_resource.config_name}.service"
    elsif platform_family?('debian', 'arch')
      "openvpn@#{new_resource.config_name}.service"
    else
      'openvpn'
    end
  end
end
