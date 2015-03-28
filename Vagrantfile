# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'openvpn-server'
  config.vm.box = 'ubuntu-14.04'
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{config.vm.box}_chef-provisionerless.box"
  config.omnibus.chef_version = 'latest'
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = File.expand_path('~/.berkshelf/cookbooks')
    # chef.log_level = :debug
    chef.json = {
    }

    chef.run_list = [
      'recipe[openvpn::default]'
    ]
  end
end
