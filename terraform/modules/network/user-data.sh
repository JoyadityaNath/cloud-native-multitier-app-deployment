#!/bin/bash
mkdir -p /etc/ecs
echo "ECS_CLUSTER=cloud-multitier-application" >> /etc/ecs/ecs.config
systemctl restart ecs