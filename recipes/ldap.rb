#
# Cookbook Name:: OpenVPN
# Recipe:: ldap
#
# Author:: Luke and Nathan
#
node.default['openvpn']['config']['plugin'] << "/usr/local/lib/openvpn-auth-ldap.so #{node['openvpn']['ldap']['config']['auth_dir']}/auth-ldap.conf"
node.default['openvpn']['config']['client-cert-not-required'] = ''

ldap_url = node['openvpn']['ldap']['source']['url']

ldap_src_filepath  = "#{Chef::Config['file_cache_path'] || '/tmp'}/threerings-openvpn-auth-ldap-#{node['openvpn']['ldap']['source']['git_commit_hash']}"

remote_file ldap_url do
  source   ldap_url
  checksum node['openvpn']['ldap']['source']['checksum']
  path     "#{ldap_src_filepath}.tar.gz"
  backup   false
end

# source install depends on the existence of the `tar` package
package 'tar'

# required to build openvpn-auth-ldap
package 're2c'
package 'gcc-4.6'
package 'g++-4.6'
package 'gobjc-4.6'

# openldap headers
package 'libldap2-dev'

# Unpack downloaded source so we could apply nginx patches
# in custom modules - example http://yaoweibin.github.io/nginx_tcp_proxy_module/
# patch -p1 < /path/to/nginx_tcp_proxy_module/tcp.patch
bash 'unarchive_source' do
  code <<-EOH
    tar zxf #{::File.basename(ldap_src_filepath)}.tar.gz -C #{::File.dirname(ldap_src_filepath)}
  EOH
  not_if { ::File.directory?(ldap_src_filepath) }
end

bash 'compile_and_configure_ldap' do
  cwd ldap_src_filepath
  code <<-EOS
    ./regen.sh && \
    ./configure --prefix=/usr/local --with-openvpn=#{node['openvpn']['source']['filepath']}/include --with-objc-runtime=GNU CC="gcc-4.6 -fPIC" OBJC=gcc-4.6 OBJCPP=cpp-4.6 && \
    make && \
    sudo make install
  EOS

  not_if { ::File.file?('/opt/ldap/ldap_openvpn.so') }
end

directory node['openvpn']['ldap']['config']['auth_dir'] do
  action :create
end

template "#{node['openvpn']['ldap']['config']['auth_dir']}/auth-ldap.conf" do
  source 'auth.conf.erb'
end
