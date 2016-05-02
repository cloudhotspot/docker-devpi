#!/bin/bash
set -e

init() {
    echo "[RUN]: Initialize devpi-server"
    devpi-server --restrict-modify root --start --host 127.0.0.1 --port 3141 --serverdir /var/lib/devpi
    devpi-server --status
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="$1"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop
}

randpw() {
  < /dev/urandom tr -dc A-Za-z-0-9 | head -c${1:-32};echo;
}

server_version=/var/lib/devpi/.serverversion

if [ ! -f $server_version ]; then
  if [ -n $DEVPI_PASSWORD]; then
    echo "[RUN]: Initializing devpi-server with provided password..."
    init $DEVPI_PASSWORD
  else
    echo "[RUN]: Initializing devpi-server with random password..."
    init randpw
  fi
fi

echo "[RUN]: Launching devpi-server"
echo "[RUN]: Options:"
echo "[RUN]:   --serverdir /var/lib/devpi"
echo "[RUN]:   --restrict-modify root"
echo "[RUN]:   --host 0.0.0.0"
echo "[RUN]:   $@"

exec devpi-server --serverdir /var/lib/devpi --restrict-modify root --host 0.0.0.0 $@