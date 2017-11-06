# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = "ubuntu/trusty64"

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.name = "partnr_vm"
  end

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  # Forward the mailcatcher ports to the host
  config.vm.network :forwarded_port, guest: 1025, host: 1111
  config.vm.network :forwarded_port, guest: 1080, host: 1080

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y build-essential zlib1g-dev git-core gnupg2 libpq-dev nodejs npm postgresql phantomjs imagemagick
    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
    curl -L https://get.rvm.io | bash -s stable --ruby
    source /home/vagrant/.rvm/scripts/rvm
    rvm install ruby-2.3.0
    source ~/.profile
    rvm use 2.3.0
    gem install bundler
    cd /vagrant
    bundle
    export AWS_REGION="us-west-2"
    gem install mailcatcher --no-ri
    npm install bower -g
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    bower install
    npm i
    sudo -u postgres -s createuser -s vagrant
    rake db:setup
  SHELL
end
