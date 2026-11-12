# frozen_string_literal: true

provides :openvpn_install
unified_mode true

property :package_name, String, default: 'openvpn'
property :install_epel, [true, false], default: true
property :install_easy_rsa, [true, false], default: false
property :install_tar, [true, false], default: true
property :install_bash, [true, false], default: true

action :install do
  package 'epel-release' do
    action :install
    only_if { new_resource.install_epel && platform_family?('rhel') }
  end

  package new_resource.package_name

  package 'easy-rsa' do
    action :install
    only_if { new_resource.install_easy_rsa }
  end

  package 'tar' do
    action :install
    only_if { new_resource.install_tar }
  end

  package 'bash' do
    action :install
    only_if { new_resource.install_bash }
  end
end

action :remove do
  package new_resource.package_name do
    action :remove
  end

  package 'easy-rsa' do
    action :remove
    only_if { new_resource.install_easy_rsa }
  end
end
