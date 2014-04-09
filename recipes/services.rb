template '/etc/init/openvpn-instance.conf' do
  source 'upstart-instance.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template '/etc/init/openvpn-launcher.conf' do
  source 'upstart-launcher.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables :conf_dir => node['openvpn']['conf_dir']
end

service 'openvpn-launcher' do
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Upstart
  action [:enable]
end
