#!/bin/bash
# Solano CI pre_setup hook (http://docs.solanolabs.com/Setup/setup-hooks/)

set -e # Exit on errors

# Install Docker Compose if it is not already installed
if [ ! -f "/usr/local/bin/docker-compose" ]; then
  sudo bash -c "curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Build Docker images
sudo docker-compose build
