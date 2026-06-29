# frozen_string_literal: true

provides :openvpn_conf
unified_mode true

property :config_name, String, name_property: true
property :config_path, [String, nil]
property :cookbook, String, default: 'openvpn'
property :config, Hash, default: {}
property :template_source, String, default: 'server.conf.erb'
property :push_routes, Array, default: []
property :push_options, Hash, default: {}
property :client_cn, String, default: 'client'

action :create do
  directory ::File.dirname(resolved_config_path) do
    owner 'root'
    group node['root_group']
    mode '0755'
    recursive true
  end

  template resolved_config_path do
    cookbook new_resource.cookbook
    source new_resource.template_source
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      config: new_resource.config,
      push_routes: new_resource.push_routes,
      push_options: new_resource.push_options,
      client_cn: new_resource.client_cn
    )
    helpers do
      def render_push_options(push_options)
        return [] if push_options.nil?

        push_options.each_with_object([]) do |(option, conf), m|
          case conf
          when Array
            conf.each { |o| m << "push \"#{option} #{o}\"" }
          when String
            m << "push \"#{option} #{conf}\""
          else
            raise "Push option data type #{conf.class} not supported"
          end
        end
      end
    end
  end
end

action :delete do
  file resolved_config_path do
    action :delete
  end
end

action_class do
  def resolved_config_path
    return new_resource.config_path if new_resource.config_path

    if (platform_family?('rhel', 'amazon') && node['platform_version'].to_i >= 8) || platform_family?('fedora')
      "/etc/openvpn/#{new_resource.config_name}/#{new_resource.config_name}.conf"
    else
      "/etc/openvpn/#{new_resource.config_name}.conf"
    end
  end
end
