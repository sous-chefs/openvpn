#
# Cookbook Name:: OpenVPN
# Recipe:: Duo
#
# Author:: Luke
#          Nathan Tsoi <nathan@vertile.com>
#
node.default['openvpn']['config']['plugin'] << "/opt/duo/duo_openvpn.so #{node['openvpn']['duo']['config']['ikey']} #{node['openvpn']['duo']['config']['skey']} #{node['openvpn']['duo']['config']['host']}"

duo_url = node['openvpn']['duo']['source']['url']

src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/duosecurity-duo_openvpn-#{node['openvpn']['duo']['source']['git_commit_hash']}"

remote_file duo_url do
  source   duo_url
  checksum node['openvpn']['duo']['source']['checksum']
  path     "#{src_filepath}.tar.gz"
  backup   false
end

# source install depends on the existence of the `tar` package
package 'tar'

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

bash 'compile_and_configure_duo' do
  cwd src_filepath
  code <<-EOS
    make && \
    sudo make install
  EOS

  not_if { ::File.file?('/opt/duo/duo_openvpn.so') }
end
