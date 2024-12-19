#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 community-scripts ORG
# Author: Stefan (stefan131)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/HabitRPG/habitica

# App Default Values
APP="Habitica"
var_tags="productivity;task-manager"
var_cpu="2"
var_ram="2048"
var_disk="4"
var_os="debian"
var_version="12"
var_unprivileged="1"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/habitica ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Stopping ${APP}"
  systemctl stop habitica.service
  msg_ok "Stopped ${APP}"

  msg_info "Pulling Latest ${APP} Version"
  cd /opt/habitica
  git pull origin master &>/dev/null
  msg_ok "Pulled Latest Version"

  msg_info "Installing Dependencies"
  npm install --production &>/dev/null
  msg_ok "Installed Dependencies"

  msg_info "Starting ${APP}"
  systemctl start habitica.service
  msg_ok "Started ${APP}"

  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"

