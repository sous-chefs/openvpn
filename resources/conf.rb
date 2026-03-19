# frozen_string_literal: true

provides :openvpn_conf
unified_mode true

default_action :create

property :config, Hash, default: {}
property :template_source, String, default: 'server.conf.erb'
property :template_cookbook, String, default: 'openvpn'
property :push_routes, Array, default: []
property :push_options, [Hash, Array], default: {}
property :conf_dir, String, default: lazy {
  if platform_family?('rhel', 'fedora')
    "/etc/openvpn/#{name}"
  else
    '/etc/openvpn'
  end
}

action :create do
  conf_path = ::File.join(new_resource.conf_dir, "#{new_resource.name}.conf")

  # RHEL/Fedora use per-instance config dirs
  if platform_family?('rhel', 'fedora')
    directory new_resource.conf_dir do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
    end
  end

  template conf_path do
    cookbook new_resource.template_cookbook
    source new_resource.template_source
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      config: new_resource.config,
      push_routes: new_resource.push_routes,
      push_options: new_resource.push_options
    )
    helpers do
      def render_push_options(push_options)
        return [] if push_options.nil?
        push_options.each_with_object([]) do |(option, conf), m|
          case conf
          when Chef::Node::ImmutableArray, Array
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
  conf_path = ::File.join(new_resource.conf_dir, "#{new_resource.name}.conf")

  file conf_path do
    action :delete
  end
end
