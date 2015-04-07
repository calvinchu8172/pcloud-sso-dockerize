# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box      = 'ubuntu/trusty64/custom'
  
  config.vm.synced_folder './work', '/vagrant', nfs: true

  config.vm.network "private_network", ip: "192.168.50.10"
  # config.vm.network :forwarded_port, guest: 8080, host: 8080
  # config.vm.network :forwarded_port, guest: 443, host:443
  # config.vm.network :forwarded_port, guest: 9324, host:9324
  config.vm.network :forwarded_port, guest: 3000, host: 3001

  config.vm.provision :shell, path: "bootstrap.sh", keep_color: true

   config.vm.provider "virtualbox" do |v|
     v.memory = 2048
     v.cpus = 2
   end
end
