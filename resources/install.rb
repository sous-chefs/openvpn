# frozen_string_literal: true

provides :openvpn_install
unified_mode true

default_action :create

property :packages, Array, default: lazy { %w(openvpn) }
property :enable_ip_forwarding, [true, false], default: true
property :use_apt_repo, [true, false], default: lazy { platform_family?('debian') }
property :use_epel, [true, false], default: lazy { platform_family?('rhel', 'amazon') }

action :create do
  apt_update

  if new_resource.use_epel
    include_recipe 'yum-epel'
  end

  if new_resource.use_apt_repo
    apt_package 'gnupg'

    apt_repository 'openvpn' do
      uri 'http://build.openvpn.net/debian/openvpn/stable/'
      key 'https://swupdate.openvpn.net/repos/repo-public.gpg'
      components ['main']
    end
  end

  new_resource.packages.each do |pkg|
    package pkg
  end

  package 'tar'

  if new_resource.enable_ip_forwarding
    sysctl 'net.ipv4.conf.all.forwarding' do
      value 1
    end

    sysctl 'net.ipv6.conf.all.forwarding' do
      value 1
      only_if { ::Dir.exist?('/proc/sys/net/ipv6') }
    end
  end
end

action :delete do
  new_resource.packages.each do |pkg|
    package pkg do
      action :remove
    end
  end
end
