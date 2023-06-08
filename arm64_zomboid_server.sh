#!/bin/bash
###### IMPORTANT ######
# The first time you run the server it must be manually launching it from start-server.sh.
# It will create the necessary files and folders and ask you to set up an admin password to access the server.
# After that you can just shut it down and use "systemctl enable zomboid-server" and "systemctl start zomboid-server" to run it. 
# Default server takes 8GB of RAM.
# This script asumes you opened ports 16261 and 16262 tcp/udp on your firewall and forwarded in the oracle cloud console for your vm instance
# Notice we are using /opt/zomboid-server as a dir but zomboid's starting script will generate files in /root. It's split in two directories but it works and you can set startup parameters.
# This is a workaround I found for the "couldn't determine 32/64 bit of java" issues.

# install java / dependencies
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git build-essential cmake gcc-arm-linux-gnueabihf openjdk-19-jdk

# enable arm hard float architecture / install dependencies
sudo dpkg --add-architecture armhf && sudo apt update
sudo apt install -y libc6:armhf libncurses5:armhf libstdc++6:armhf

# clone and build Box86
git clone https://github.com/ptitSeb/box86
cd box86 && mkdir -p build && cd build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
sudo make install
sudo systemctl restart systemd-binfmt
cd ../..

# clone and build Box64
git clone https://github.com/ptitSeb/box64.git
cd box64 && mkdir -p build && cd build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
sudo make install
sudo systemctl restart systemd-binfmt
cd ../..

# steamcmd setup
mkdir steamcmd && cd steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# update steamcmd
./steamcmd.sh +quit > /dev/null

# set up and download zomboid server
sudo mkdir -p /opt/zomboid-server/
sudo chown -R $USER:$USER /opt/zomboid-server/
./steamcmd.sh +@sSteamCmdForcePlatformType linux +login anonymous +force_install_dir /opt/zomboid-server/ +app_update 380870 validate +quit > /dev/null

# sets up zomboid as a systemd service
sudo tee /etc/systemd/system/zomboid-server2.service > /dev/null <<EOL
[Unit]
Description=Zomboid
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=/opt/zomboid-server
ExecStart=/opt/zomboid-server/start-server.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
