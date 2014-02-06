# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos-6.3-64"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130309.box"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.define "web" do |web|
    web.vm.network "private_network", ip: "192.168.33.10"

    web.vm.host_name = "web.dev"

    web.vm.synced_folder "./shared/www", "/www", "mount_options" => ['dmode=777','fmode=777']
    web.vm.synced_folder "./shared/logs", "/logs", "mount_options" => ['dmode=777','fmode=777']

    web.vm.provision :puppet,
      :options => ["--fileserverconfig=fileserver.conf"],
      :facter => { "fqdn" => "vagrant.vagrantup.com" }  do |puppet|
         puppet.manifests_path = "manifests"
         puppet.manifest_file = "web.pp"
         puppet.module_path = "modules"
    end
  end

  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.33.11"

    db.vm.host_name = "db.dev"

    db.vm.synced_folder "./db", "/db_files", "mount_options" => ['dmode=777','fmode=777']

    db.vm.provision :puppet,
      :options => ["--fileserverconfig=fileserver.conf"],
      :facter => { "fqdn" => "vagrant.vagrantup.com" }  do |puppet|
         puppet.manifests_path = "manifests"
         puppet.manifest_file = "db.pp"
         puppet.module_path = "modules"
    end
  end
end
