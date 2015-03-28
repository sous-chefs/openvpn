# -*- mode: ruby -*-
# vi: set ft=ruby :

# http://docs.vagrantup.com/v2/multi-machine/

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-14.04'
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{config.vm.box}_chef-provisionerless.box"
  config.omnibus.chef_version = 'latest'
  config.berkshelf.enabled = true
  config.vm.network 'private_network', type: 'dhcp'

  config.vm.define 'server', primary: true do |server|
    server.vm.hostname = 'openvpn-server'
    server.vm.network 'private_network', ip: '192.168.50.4'

    # server.vm.provider 'virtualbox' do |v|
    #  v.gui = true
    # end

    server.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = File.expand_path('~/.berkshelf/cookbooks')
      # chef.log_level = :debug
      chef.json = {
      }

      chef.run_list = [
        'recipe[openvpn::server]'
      ]
    end
  end

  config.vm.define 'client' do |client|
    client.vm.hostname = 'openvpn-client'

    # client.vm.provider 'virtualbox' do |v|
    #  v.gui = true
    # end

    client.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = File.expand_path('~/.berkshelf/cookbooks')
      # chef.log_level = :debug
      chef.json = {
        'openvpn' => {
          'gateway' => '192.168.50.4'
        }
      }

      chef.run_list = [
        'recipe[openvpn::client]'
      ]
    end
  end
end
