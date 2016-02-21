#! /bin/sh -e

sudo mkdir -p /etc/openvpn/keys

echo 'Fetching client ovpn profile...'
su vagrant -c 'sftp -oStrictHostKeyChecking=no 172.19.18.8:/home/vagrant/test.tar.gz /home/vagrant/'
cd /home/vagrant
tar zxvf test.tar.gz
sudo cp -v test.conf /etc/openvpn/client.conf
sudo cp -v ca.crt /etc/openvpn/
sudo cp -v test.crt /etc/openvpn/
sudo cp -v test.key /etc/openvpn/
