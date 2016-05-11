#!/bin/bash
set -e
export DEVPI_SERVERDIR=${DEVPI_SERVERDIR:-/var/lib/devpi}

extract() {
  mkdir /tmp/extract
  for backup in /devpi-init.d/*; do
     case "$backup" in
      *.bz2) 
        echo "$0: Extracting $backup"
        tar xjvf $backup -C /tmp/extract/
        devpi-server --import /tmp/extract/*
        ;;
     esac
  done
}

start_devpi() {
  echo "[RUN]: Start devpi server"
  devpi-server --restrict-modify root --start --host 127.0.0.1 --port 3141
  devpi-server --status
  devpi use http://localhost:3141
  devpi login root --password=''
}

stop_devpi() {
  echo "[RUN]: Stop devpi server"
  devpi-server --stop
}

check_user() {
  if [[ -n $user_exists ]]; then
    devpi user -m $devpi_user password=$devpi_password  
  else
    devpi user -c $devpi_user password=$devpi_password
  fi
}

check_index() {
  devpi login $devpi_user --password=$devpi_password
  index_exists=$(devpi index -l | grep ${devpi_user}/${devpi_index} || true)
  if [[ -z $index_exists ]]; then
    devpi index -c $devpi_index bases=root/pypi
  fi
}

init_user() {
  if [[ -n $devpi_user ]]; then
    echo "[RUN]: Create user $devpi_user"
    user_exists=$(devpi user -l | grep $devpi_user || true)
    check_user
    if [[ -n $devpi_index ]]; then
      check_index
    fi
  fi
}

init() {
    extract
    start_devpi
    devpi user -m root password="$devpi_root_password"
    devpi index -y -c public pypi_whitelist='*'
    init_user
    stop_devpi
}

randpw() {
  < /dev/urandom tr -dc A-Za-z-0-9 | head -c${1:-32};echo;
}

server_version=/var/lib/devpi/.serverversion
devpi_root_password=${DEVPI_ROOT_PASSWORD:-$(randpw)}
devpi_user=${DEVPI_USER}
devpi_password=${DEVPI_PASSWORD}
devpi_index=${DEVPI_INDEX}
devpi_port=${DEVPI_PORT:-3141}

if [[ ! -f $server_version ]]; then
  echo "[RUN]: Initialize devpi-server"
  init
fi

echo "[RUN]: Launch devpi-server"
echo "[RUN]: Options:"
echo "[RUN]:   --serverdir $DEVPI_SERVERDIR"
echo "[RUN]:   --restrict-modify root"
echo "[RUN]:   --host 0.0.0.0"
echo "[RUN]:   --port $devpi_port"
echo "[RUN]:   $@"

exec devpi-server --restrict-modify root --host 0.0.0.0 --port $devpi_port $@