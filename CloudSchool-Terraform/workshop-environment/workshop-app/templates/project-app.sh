#!/bin/sh
set -o xtrace
sudo -i
apt update
cd $HOME

wget https://packages.chef.io/files/stable/chefdk/4.13.3/ubuntu/20.04/chefdk_4.13.3-1_amd64.deb
apt -y install ./chefdk_4.13.3-1_amd64.deb

apt -y install git

apt -y install unzip

git clone https://github.com/EliranKasif/CloudSchool-DEVOPS.git


echo "${main-instance_local_ipv4}  main.services" >> /etc/hosts

wget https://releases.hashicorp.com/consul-template/0.25.2/consul-template_0.25.2_linux_amd64.zip
unzip consul-template_0.25.2_linux_amd64.zip
sudo mv consul-template /usr/local/bin/

chef-solo -c ./CloudSchool-DEVOPS/Chef/solo.rb -j ./CloudSchool-DEVOPS/Chef/runlist.json --chef-license accept

#consul-template -config ./CloudSchool-DEVOPS/DockerCompose/WorkerInstance/consul-config.hcl > /var/log/consul_template.log 2>&1 &


