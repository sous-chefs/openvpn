#! /bin/sh -e

echo 'Copying ovpn profile to /home/vagrant/'
su vagrant -c "ssh -oStrictHostKeyChecking=no vagrant@172.19.18.8 \
  'sudo cp -v /etc/openvpn/keys/test.tar.gz /home/vagrant/ && \
  sudo chown -v vagrant /home/vagrant/test.tar.gz'"
