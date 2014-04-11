template '/etc/init/openvpn-instance.conf' do
  source 'upstart-instance.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables :conf_dir => node['openvpn']['conf_d_dir']
end

template '/etc/init/openvpn-launcher.conf' do
  source 'upstart-launcher.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables :conf_dir => node['openvpn']['conf_d_dir']
end

directory node['openvpn']['conf_d_dir'] do
  owner 'root'
  group 'root'
  mode 0640
end

service 'openvpn-launcher' do
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Upstart
  action [:enable]
end
