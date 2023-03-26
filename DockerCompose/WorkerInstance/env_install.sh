#!/bin/sh
set -o xtrace
sudo -i
apt update
cd $HOME
export CHEFDKVER=4.13.3
wget https://packages.chef.io/files/stable/chefdk/${CHEFDKVER}/ubuntu/20.04/chefdk_${CHEFDKVER}-1_amd64.deb
apt -y install ./chefdk_${CHEFDKVER}-1_amd64.deb

apt -y install git-all

apt install unzip

git clone https://github.com/EliranKasif/CloudSchool-DEVOPS.git

apt -y install pip

pip install -r ./CloudSchool-DEVOPS/PythonRestApi/code/requirements.txt

apt-get -y install libmysqlclient-dev
pip3 -y install mysqlclient

echo "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)  main.services" >> /etc/hosts

wget https://releases.hashicorp.com/consul-template/0.25.2/consul-template_0.25.2_linux_amd64.zip
unzip consul-template_0.25.2_linux_amd64.zip
sudo mv consul-template /usr/local/bin/

consul-template -config ./CloudSchool-DEVOPS/DockerCompose/WorkerInstance/consul-config.hcl

