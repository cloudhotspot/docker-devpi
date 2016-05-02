# Devpi Docker Image

[![](https://imagelayers.io/badge/cloudhotspot/devpi:latest.svg)](https://imagelayers.io/?images=cloudhotspot/devpi:latest 'Get your own badge on imagelayers.io')

This repository includes a Dockerfile that builds a lightweight Devpi server based upon Alpine Linux.

## Initialization

This image exposes the Devpi server directory on /var/lib/devpi.  If no existing data is detected in this directory, the Devpi server will be initialised with a root password provided via the `DEVPI_PASSWORD` environment variable, or a 32 character random password if this environment variable is not defined.

## Default Networking

By default, Devpi listens on port 3141 and you must map this port if you do not supply a custom port configuration option:

`docker run -d --name devpi -p 3141:3141 cloudhotspot/devpi`

You can run Devpi on a custom port by supplying the `--port <port>` option as a command argument:

`docker run -d --name devpi -p 8000:8000 cloudhotspot/devpi --port 8000`