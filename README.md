# Devpi Docker Image

[![](https://imagelayers.io/badge/cloudhotspot/devpi:latest.svg)](https://imagelayers.io/?images=cloudhotspot/devpi:latest 'Get your own badge on imagelayers.io')

This repository includes a Dockerfile that builds a lightweight [Devpi](http://doc.devpi.net/latest/) server based upon Alpine Linux. 

[The current published image size](https://hub.docker.com/r/cloudhotspot/devpi/) is ~29MB and the virtual size is ~90MB.

### Initialization

This image configures the Devpi server directory as `/var/lib/devpi`.  

If no existing data is detected in this directory, the Devpi server will be initialised with a root password provided via the `DEVPI_ROOT_PASSWORD` environment variable, or a 32 character random password if this environment variable is not defined.

You can also use the following initialization environment variables:

- `DEVPI_USER` - adds a new user.  If you restore from a Devpi backup, no action is taken if this user already exists
- `DEVPI_PASSWORD` - sets the password for the new user.  If you restore from a Devpi backup and the user already exists, the user password is updated to the new password
- `DEVPI_INDEX` - creates an index for the user that is based from the default `root/pypi` index.  The new index path will be `$DEVPI_USER/$DEVPI_INDEX`. 

For example given the following settings:

- `DEVPI_USER` = dev
- `DEVPI_PASSWORD` = xyz123
- `DEVPI_INDEX` = root

The path to the index will be `http://<server>:<port>/dev/root`.

### Running the Image

This image runs the following entrypoint:

`devpi-server --serverdir /var/lib/devpi --restrict-modify root --host 0.0.0.0`

You can add an array of additional flags as command arguments:

`docker run -d --name devpi cloudhotspot/devpi <arg> [<arg> ...]`

### Default Networking

By default, Devpi listens on port 3141 and you must map this port if you do not supply a custom port configuration option:

`docker run -d --name devpi -p 3141:3141 cloudhotspot/devpi`

You can run Devpi on a custom port by setting the environment variable `DEVPI_PORT` option:

`docker run -d --name devpi -p 8000:8000 -e DEVPI_PORT=8000 cloudhotspot/devpi`

### Devpi Server Data Directory

By default the devpi server will use `/var/lib/devpi-server` as its data directory.  

You can override this my setting the `DEVPI_SERVERDIR` environment variable:

`docker run -d --name devpi -e DEVPI_SERVERDIR=/mnt/devpi -e DEVPI_PORT=8000 -p 8000:8000 cloudhotspot/devpi`

### Importing Server State

The entrypoint script looks in a directory called /devpi-init.d, extracts all *.bz2 files to a temporary folder and then attempts to import the contents of the extract files into devpi.  This is useful if you have previously exported the state of a previous Devpi server.  

> **NOTE**: Importing a backup and initial indexing can take some time.  Use the `docker log` or `docker-compose log` command to watch the progress of Devpi initialization.

See the [devpi-server administration docs](http://doc.devpi.net/latest/adminman/server.html) for more details on exporting and importing server state.

### Sample Docker Compose File

This repository includes a sample `docker-compose.yml` file.  

Note this sample assumes you have exported and compressed previous devpi server state to a file called `backup.bz2` and have set an environment variable `DEVPI_PASSWORD`.  

To use the Docker Compose file:

1. Create an external docker volume called `devpi_data` by running `docker volume create --name devpi_data`
1. Run `docker-compose up -d`.  Devpi will be running on port 8000.
1. Your Devpi data directory will be persisted to the `devpi_data` volume.

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
    environment:
      DEVPI_USER: dev
      DEVPI_PASSWORD: ${DEVPI_PASSWORD}
      DEVPI_PORT: "8000"
```


