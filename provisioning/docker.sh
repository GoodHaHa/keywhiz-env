#!/bin/bash

sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates expect gettext-base
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

sudo echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main'>/tmp/docker.list
sudo mv /tmp/docker.list /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get -y install docker-engine
sudo usermod -G docker ubuntu
echo "--- docker installed --- "

sudo apt-get -y install jq git fuse

echo 'user_allow_other'>>/etc/fuse.conf

git clone https://github.com/gyulaweber/keywhiz-env.git
cd keywhiz-env
sudo ./everything.sh
sudo ./test.sh
