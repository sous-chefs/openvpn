if defined?(ChefSpec)
  def create_openvpn_users(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvpn_users, :create, resource_name)
  end

  def remove_openvpn_users(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openvpn_users, :remove, resource_name)
  end
end
