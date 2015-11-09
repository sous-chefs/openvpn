#
# Cookbook Name:: OpenVPN
# Recipe:: Duo
#
# Author:: Luke
#          Nathan Tsoi <nathan@vertile.com>
#
url = node['openvpn']['source']['url']

src_filepath = node.default['openvpn']['source']['filepath'] = "#{Chef::Config['file_cache_path'] || '/tmp'}/openvpn-#{node['openvpn']['source']['version']}"

remote_file url do
  source   url
  checksum node['openvpn']['source']['checksum']
  path     "#{src_filepath}.tar.gz"
  backup   false
end

# source install depends on the existence of the `tar` package
%w/tar libssl-dev liblzo2-dev libpam0g-dev/.each do |pkg|
  package pkg
end

# Unpack downloaded source so we could apply nginx patches
# in custom modules - example http://yaoweibin.github.io/nginx_tcp_proxy_module/
# patch -p1 < /path/to/nginx_tcp_proxy_module/tcp.patch
bash 'unarchive_source' do
  cwd  ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)}.tar.gz -C #{::File.dirname(src_filepath)}
  EOH
  not_if { ::File.directory?(src_filepath) }
end

bash 'compile_and_configure' do
  cwd src_filepath
  code <<-EOS
    ./configure CC=gcc-4.6 OBJC=gcc-4.6 OBJCPP=cpp-4.6 && \
    make && \
    sudo make install
  EOS
  not_if { ::File.file?('/usr/local/sbin/openvpn') }
end
