# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip:"192.168.33.20"
  
  config.vm.provider"virtualbox"do |vb|
    vb.memory ="1024"
  end

  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = "chef-repo/cookbooks"
    chef.add_recipe "chef_p3"
  end

end
