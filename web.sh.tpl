#!/bin/bash
set -eux

sudo dnf -y update
sudo dnf -y install nginx

sudo systemctl enable nginx.service
sudo systemctl start nginx.service
