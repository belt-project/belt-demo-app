#!/usr/bin/env bash
set -eo pipefail

BELT_ENV_TOOLBOX_TOOLS="caddy"

source /dev/stdin <<< "$(curl -Lsm 2 https://get.belt.sh)"

install_caddy() {
  echo -n "==> Installing caddy "
  caddy_install
  echo "OK"
}

deploy_app() {
  echo -n "==> Uploading app archive "
  app_upload "./belt-demo.tar.gz"
  echo "OK"

  echo -n "==> Stopping process "
  systemd_unit_stop "belt-demo" "ignore errors"
  echo "OK"

  echo -n "==> Setting up user "
  user_add "belt-demo"
  echo "OK"

  echo -n "==> Copying files "
  app_copy_file "belt-demo-app"
  app_copy_file ".env"
  echo "OK"

  echo -n "==> Setting up permissions "
  app_set_permissions "belt-demo:belt-demo"
  echo "OK"

  echo -n "==> Copying unit file "
  systemd_add_unit "belt-demo.service"
  echo "OK"

  echo -n "==> Starting process "
  systemd_unit_start "belt-demo"
  echo "OK"

  echo -n "==> Adding caddy vhost "
  caddy_add_vhost
  echo "OK"

  echo -n "==> Restarting caddy "
  caddy_restart
  echo "OK"
}

belt_begin_session "root" "demo.belt.sh"

install_caddy
deploy_app
