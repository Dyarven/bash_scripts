#!/bin/bash
set -e

# Automated docker & docker-compose install
docker_autoinst() {
  #instalaciónn de docker linux param.
  curl -fsSL https://get.docker.com | bash
  #compose
  $dockerPath="/usr/local/bin/docker-compose"
  version=$( curl https://github.com/docker/compose/releases/latest | cut -d"/" -f 8 | cut -d"\"" -f 1 )
  version=$( expr ${version} )
  curl -fssL "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o $dockerPath
}

docker_autoinst

# Enables docker service and adds user to group
chmod +x /usr/local/bin/docker-compose
systemctl enable docker && systemctl start docker
usermod -aG docker $(whoami)

# Sets up portainer agent
docker volume create portainer_data
docker run -d --name=portainer --restart=always \
 -p 8000:8000 -p 9000:9000 \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v portainer_data:/data portainer/portainer-ce
