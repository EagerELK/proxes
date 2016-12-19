# frozen_string_literal: true
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'

  config.vm.network :private_network, ip: '172.16.248.110'

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '2048'
  end

  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    # Dependencies / Utilities
    sudo apt-get update
    sudo apt-get install -y screen curl git build-essential libssl-dev

    # Ruby
    # sudo apt-get install -y ruby2.3 ruby2.3-dev
    if [ ! -f /home/vagrant/.rvm/scripts/rvm ]
    then
        gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
        \\curl -sSL https://get.rvm.io | bash
    fi
    source /home/vagrant/.rvm/scripts/rvm

    # Ruby and it's Gems
    cd /vagrant
    rvm use $(cat .ruby-version) --install
    gem install bundler --no-rdoc --no-ri
    bundle install

    # Node
    # if [ ! -f /home/vagrant/.nvm/nvm.sh ]
    # then
    #   \\curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
    # fi
    # export NVM_DIR="/home/vagrant/.nvm"
    # [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    # # Node and it's packages
    # nvm install `cat .nvmrc`
    # npm install --no-bin-links
  SHELL
end
