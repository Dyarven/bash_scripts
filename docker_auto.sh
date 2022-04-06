#!/bin/bash
set -euo pipefail

#executa un script de instalación automatizado de docker
curl -sSL https://get.docker.com | bash

#instala docker compose
$dockerPath=${dockerPath:-/usr/local/bin/docker-compose}
curl -SL "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o $dockerPath


#activa o servizo docker e pon ao usuario no grupo
chmod +x /usr/local/bin/docker-compose
systemctl enable docker && systemctl start docker
usermod -aG docker $(whoami)

#instala e inicia o axente portainer 
docker volume create portainer_data
docker run -d --name=portainer --restart=always \
 -p 8000:8000 -p 9000:9000 \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v portainer_data:/data portainer/portainer-ce