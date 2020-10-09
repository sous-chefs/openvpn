#
# Cookbook:: openvpn
# Recipe:: apt-repo
#

apt_update 'all platforms' do
  action :nothing
end

apt_package 'gnupg' do
  action :install
  notifies :update, 'apt_update[all platforms]', :before
end

apt_repository 'openvpn' do
  uri        'http://build.openvpn.net/debian/openvpn/stable/'
  key        'https://swupdate.openvpn.net/repos/repo-public.gpg'
  components ['main']
end
