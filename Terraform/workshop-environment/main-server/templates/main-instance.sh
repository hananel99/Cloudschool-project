#!/bin/sh
set -o xtrace
sudo -i
apt update
cd ~

apt -y install git

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

git clone https://github.com/EliranKasif/CloudSchool-DEVOPS.git

export DATABASE_URL=${database_url_terraform}
export DATABASE_USERNAME=${database_username_terraform}
export DATABASE_PASSWORD=${database_password_terraform}
export VAULT_ADDR="http://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8200"

docker-compose -f ./CloudSchool-DEVOPS/DockerCompose/MainInstance/docker-compose.yml up --detach

sleep 10

docker exec -i vault-server bin/sh < ./CloudSchool-DEVOPS/DockerCompose/MainInstance/vault_init_database.sh

docker exec -i consul-server1 bin/sh < ./CloudSchool-DEVOPS/DockerCompose/MainInstance/consul_kv_init.sh

