#!/usr/bin/env bash

# Docker on Ubuntu 24.04

sudo apt update && sudo apt upgrade -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# 3. Docker Service starten + autostart
sudo systemctl start docker
sudo systemctl enable docker

# 4. User zur docker Gruppe (passwordless)
sudo usermod -aG docker $USER
newgrp docker  # Oder logout/login

# 5. Test
docker run --rm hello-world
