# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# This Vagrantfile configures an image suitable for building a new metasploit-installer package.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/precise64"
  config.vm.provision "shell", inline: 'sudo apt-get -y install build-essential git ruby1.9.1 ruby1.9.1-dev bison flex'
  config.vm.provision "shell", inline: 'sudo gem install bundler'
  config.vm.provision "shell", inline: 'sudo mkdir -p /var/cache/omnibus'
  config.vm.provision "shell", inline: 'sudo mkdir -p /opt/metasploit-framework'
  config.vm.provision "shell", inline: 'sudo apt-get -y remove ruby1.8'
  config.vm.provision "shell", inline: 'sudo apt-get -y autoremove'
  config.vm.provision "shell", inline: 'sudo chown vagrant /var/cache/omnibus'
  config.vm.provision "shell", inline: 'sudo chown vagrant /opt/metasploit-framework'

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 4096
  end
end
