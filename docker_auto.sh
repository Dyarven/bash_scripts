#!/bin/bash
set -e

#docker e docker-compose instalación auto
docker_autoinst() {
  #script inst docker linux param.
  curl -fsSL https://get.docker.com | bash
  #compose
  $dockerPath="/usr/local/bin/docker-compose"
  version=$( curl https://github.com/docker/compose/releases/latest | cut -d"/" -f 8 | cut -d"\"" -f 1 )
  version=$( expr ${version} )
  curl -fssL "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o $dockerPath
}

docker_autoinst

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
