#! /opt/chef/embedded/bin/ruby

require 'net/http'
require 'fileutils'

puts 'Retrieving insecure key from GitHub...'

url = 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant'
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
pk = response.body

puts 'Writing insecure key to /home/vagrant/.ssh/id_rsa'

IO.write('/home/vagrant/.ssh/id_rsa', pk)
FileUtils.chown 'vagrant', 'root', '/home/vagrant/.ssh/id_rsa'
FileUtils.chmod 0o400, '/home/vagrant/.ssh/id_rsa'
