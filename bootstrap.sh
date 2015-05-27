#!/usr/bin/env bash

sudo locale-gen zh_TW.UTF-8
sudo cp /etc/apt/sources.list /etc/apt/sources.list.cp
sudo sed -i 's/archive.ubuntu.com/free.nchc.org.tw/g' /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y git git-flow
sudo apt-get install -y mysql-common mysql-client libmysqlclient-dev

# Add for mysql server
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 12345678'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 12345678'
sudo apt-get install -y mysql-server

su - vagrant -c  'cd /home/vagrant'
su - vagrant -c  'curl -sSL https://rvm.io/mpapis.asc | gpg --import -'
su - vagrant -c  'curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.2'
su - vagrant -c  'source /home/vagrant/.rvm/scripts/rvm'
su - vagrant -c  'gem install bundler'

# pcloud custom
sudo apt-get install -y imagemagick libmagickwand-dev qt5-default libqt5webkit5-dev nodejs redis-server
