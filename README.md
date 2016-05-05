# Devpi Docker Image

[![](https://imagelayers.io/badge/cloudhotspot/devpi:latest.svg)](https://imagelayers.io/?images=cloudhotspot/devpi:latest 'Get your own badge on imagelayers.io')

This repository includes a Dockerfile that builds a lightweight [Devpi](http://doc.devpi.net/latest/) server based upon Alpine Linux. 

[The current published image size](https://hub.docker.com/r/cloudhotspot/devpi/) is ~29MB and the virtual size is ~90MB.

### Initialization

This image configures the Devpi server directory as `/var/lib/devpi`.  

If no existing data is detected in this directory, the Devpi server will be initialised with a root password provided via the `DEVPI_PASSWORD` environment variable, or a 32 character random password if this environment variable is not defined.

This image runs the following entrypoint:

`devpi-server --serverdir /var/lib/devpi --restrict-modify root --host 0.0.0.0`

You can add an array of additional flags such as `--port <port>` as command arguments:

`docker run -d --name devpi cloudhotspot/devpi <arg> [<arg> ...]`

### Default Networking

By default, Devpi listens on port 3141 and you must map this port if you do not supply a custom port configuration option:

`docker run -d --name devpi -p 3141:3141 cloudhotspot/devpi`

You can run Devpi on a custom port by supplying the `--port <port>` option as a command argument:

`docker run -d --name devpi -p 8000:8000 cloudhotspot/devpi --port 8000`

### Devpi Server Data Directory

By default the devpi server will use `/var/lib/devpi-server` as its data directory.  

You can override this my setting the `DEVPI_SERVERDIR` environment variable:

`docker run -d --name devpi -e DEVPI_SERVERDIR=/mnt/devpi -p 8000:8000 cloudhotspot/devpi --port 8000`

### Importing Server State

The entrypoint script looks in a directory called /devpi-init.d, extracts all *.bz2 files to a temporary folder and then attempts to import the contents of the extract files into devpi.  This is useful if you have previously exported the state of a previous Devpi server.  

See the [devpi-server administration docs](http://doc.devpi.net/latest/adminman/server.html) for more details on exporting and importing server state.

### Sample Docker Compose File

This repository includes a sample `docker-compose.yml` file.  Note this sample assumes you have exported and compressed previous devpi server state to a file called `backup.bz2`:

```
version: '2'

volumes:
  devpi_data:
    external: true

services:
  devpi:
    image: cloudhotspot/devpi
    volumes:
      - devpi_data:/var/lib/devpi
      - ./backup.bz2:/devpi-init.d/backup.bz2
    ports:
      - "8000:8000"
    stop_signal: SIGINT
    command: "--port 8000"
```

To use the Docker Compose file:

1. Create an external docker volume called `devpi_data` by running `docker volume create --name devpi_data`
1. Run `docker-compose up -d`.  Devpi will be running on port 8000.
