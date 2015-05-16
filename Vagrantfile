# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# This Vagrantfile configures an image suitable for building a new metasploit-installer package.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", inline: 'sudo apt-get -y install build-essential git ruby bundler ruby-dev bison flex'
  config.vm.provision "shell", inline: 'sudo mkdir -p /var/cache/omnibus'
  config.vm.provision "shell", inline: 'sudo mkdir -p /opt/metasploit-framework'
  config.vm.provision "shell", inline: 'sudo chown vagrant /var/cache/omnibus'
  config.vm.provision "shell", inline: 'sudo chown vagrant /opt/metasploit-framework'

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 4096
  end
end
