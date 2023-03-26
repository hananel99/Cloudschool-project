#!/bin/sh
set -o xtrace
sudo -i
apt update
cd ~
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
git clone https://github.com/EliranKasif/CloudSchool-DEVOPS.git

docker-compose -f ./CloudSchool-DEVOPS/DockerCompose/JenkinsInstance/docker-compose.yml up --detach

