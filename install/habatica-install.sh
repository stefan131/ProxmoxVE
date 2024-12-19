#!/usr/bin/env bash

# Copyright (c) 2021-2024 community-scripts ORG
# Author: Stefan (stefan131)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get update
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y build-essential
$STD apt-get install -y libkrb5-dev
$STD apt-get install -y python3
$STD apt-get install -y python3-pip
$STD curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
$STD apt-get install -y nodejs
$STD apt-get install -y npm
$STD npm install -g npm@6
$STD npm install -g mocha
# $STD apt-get install -y mongodb
msg_ok "Installed Dependencies"

# msg_info "Installing Node.js and npm (v14 and v6)"
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# $STD apt-get install -y nodejs
# $STD apt-get install -y npm
# npm install -g npm@6
# $STD npm install -g mocha
# msg_ok "Installed Node.js and npm"

msg_info "Installing Habitica"
$STD git clone https://github.com/HabitRPG/habitica.git /opt/habitica
cd /opt/habitica
$STD cp config.json.example config.json
$STD npm install

msg_info "Creating Habitica Service"
service_path_mongo="/etc/systemd/system/habitica-mongo.service"
echo "[Unit]
Description=Habitica MongoDB Development Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/habitica
ExecStart=/usr/bin/npm run mongo:dev
Restart=always
User=root

[Install]
WantedBy=multi-user.target" >$service_path_mongo

# API Server Service
service_path_api="/etc/systemd/system/habitica-api.service"
echo "[Unit]
Description=Habitica API Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/habitica
ExecStart=/usr/bin/npm start
Restart=always
User=root

[Install]
WantedBy=multi-user.target" >$service_path_api

# Client Service
service_path_client="/etc/systemd/system/habitica-client.service"
echo "[Unit]
Description=Habitica Client Development Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/habitica
ExecStart=/usr/bin/npm run client:dev
Restart=always
User=root

[Install]
WantedBy=multi-user.target" >$service_path_client

$STD systemctl daemon-reload
$STD systemctl enable --now habitica-mongo.service habitica-api.service habitica-client.service
msg_ok "Created Habitica Services"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
