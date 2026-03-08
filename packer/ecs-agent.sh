#!/usr/bin/env bash
set -e

curl -O https://s3.ap-south-1.amazonaws.com/amazon-ecs-agent-ap-south-1/amazon-ecs-init-latest.amd64.deb
sudo dpkg -i amazon-ecs-init-latest.amd64.deb

sudo mkdir -p /etc/ecs

# Add systemd override
sudo mkdir -p /etc/systemd/system/ecs.service.d

cat <<EOF | sudo tee /etc/systemd/system/ecs.service.d/override.conf
[Unit]
After=docker.service cloud-final.service
EOF

sudo systemctl daemon-reload
sudo systemctl enable ecs