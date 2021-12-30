# docker-minecraft-bedrock-backup

[![Docker Pulls](https://img.shields.io/docker/pulls/kaiede/minecraft-bedrock-backup.svg)](https://hub.docker.com/r/kaiede/minecraft-bedrock-backup)
[![GitHub Issues](https://img.shields.io/github/issues-raw/kaiede/docker-minecraft-bedrock-backup.svg)](https://github.com/kaiede/docker-minecraft-bedrock-backup/issues)
[![Build](https://github.com/kaiede/docker-minecraft-bedrock-backup/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/kaiede/docker-minecraft-bedrock-backup/actions?query=workflow%3A%22Docker+Image+CI%22)
[![Release Notes](https://img.shields.io/badge/Release-1.0.2-brightgreen.svg?style=flat)](https://github.com/Kaiede/docker-minecraft-bedrock-backup/releases)

Docker container for configuring backups of the Minecraft [Bedrock](https://hub.docker.com/r/itzg/minecraft-bedrock-server) [Java](https://hub.docker.com/r/itzg/minecraft-server) docker containers provided by itzg.

### Features

- Bedrock backups use the .mcworld format, meaning Vanilla worlds can be imported using any Bedrock client.
- Java backups use the same .zip backup format as the game client, making them easier to work with.
- Takes snapshots while the server is running.
- Supports trimming backups to limit disk space usage.

### Usage

There's a couple of steps required to properly configure this service, since it integrates with both docker and the minecraft server containers you are running. You can find a full example of the configuration files in the `Examples` folder on GitHub. 

* [Note File Locations](#note-file-locations)
* [Setup docker-compose.yml](#configure-docker-compose-file)
* [Configure Permissions](#configure-permissions)
* [Setup config.json](#configure-backup-service)
* [Run](#run)

### Note File Locations

Backups require access to three locations. Make a note of these. 

* Your `docker.sock` file. 
  * If you don't know how to look this up, run `echo $DOCKER_HOST` this will either be blank, or something like `/run/user/1000/docker.sock`, if it is blank, check to see if `/var/run/docker.sock` exists and use that.
* Your bedrock server folder. 
  * This will either be a named volume, or a folder on the host. As an example, we will be using `/opt/bedrock/server`.
* Where you want to put backups.
  * You will create this yourself. It's recommended to use a host folder. As an example, we will be using `/opt/bedrock/backups`.

### Configure Docker Compose File

In your `docker-compose.yml` file where you configure your minecraft server, you will want to make sure your server container has a couple options set so that the container can be attached to and have commands issued to it:

```
    stdin_open: true
    tty: true
```

Once the options are set on your server container(s), you will want to add another service that will run the backups:

```
  backup:
    image: kaiede/minecraft-bedrock-backup
    name: minecraft_backup
    restart: always
    depends_on:
      - "bedrock_server"
    environment:
      TZ: "America/Los_Angeles"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/bedrock/backups:/backups
      - /opt/bedrock/server:/server
```

The service should always depend on all the bedrock servers listed in your `docker-compose.yml` file. We want to let the minecraft servers start before taking a backup on launch. It is recommended to set `container_name` for each server that will be backed up for ease of configuration later.

In most cases, you only need to configure the timezone for the container, but there are more variables available. [A full list is available here](doc/VARIABLES.md).
* `TZ`: This sets the timezone. It is optional, but it will use GMT if not set.

For the volumes, they need to be configured as such:
* Map in `docker.sock`. The above example should work fine for when docker runs as root. When running rootless, take the value you found earlier and include it like so: `/run/user/1000/docker.sock:/var/run/docker.sock`
* Map in your backups folder. In our example, we put it at `/opt/bedrock/backups` on our host. It should always be mapped into `/backups` in the container.
* Map in each server folder. This can be mapped anywhere in the container, but we use `/server` above for simplicity.

### Configure Permissions

In many cases, the default behavior of having the user and group set from your `/backups` folder will work fine and is recommended. However, if you need to override this or are having permissions issues, [more detail is available here](doc/PERMISSIONS.md).

### Configure Backup Service

Inside your backups folder, you will need to create a `config.yml` file. A quick overview is below, while [more detail is available here](doc/TOOL_CONFIG.md)

> NOTE: The previous JSON format is still supported in backwards-compatibility, but it is recommended to switch to using YML, which is more readable

```
containers:
  bedrock:
    - name: bedrock_server
      worlds:
        - /server/worlds/MyWorld
trim:
  trimDays: 2
  keepDays: 14
  minKeep: 2
```

Containers has two sub-nodes, `bedrock` and `java`. Under each is a list of containers you want to backup. `name` is the name of the docker container and must match the one provided by `docker ps`, or `container_name` in your `docker-compose.yml` file. `worlds` is another list of paths to each world. This path is the backup container's file path to the world. So in the example above, `/opt/bedrock/server/worlds/MyWorld` will become `/server/worlds/MyWorld` in the config file.

Make sure to put each server under the correct heading, as doing live backups is slightly different for each, and the service needs to know which type it is working with. 

> NOTE: The previous "servers" list is supported via backwards-compatibility, but has been deprecated. It's recommended you update to using 

The basic trim settings above will keep backups for 14 days, only keep 1 backup per day after 2 days, and always keep a minimum of 2 backups per world. Trimming is [discussed in detail here](doc/TOOL_CONFIG.md). 

### Run

Run `docker-compose up` once the above steps are done to verify via the console that the first backup is successful. Then you can stop the containers and restart them using `docker-compose start` to run them in the background like you normally would. 

### Restoring Backups

See [Restoring Backups](doc/RESTORING.md)

### Credits

This was built in part by understanding how itzg/mc-backup works for Java, and is offered under similar license: https://github.com/itzg/docker-mc-backup 

Leverages BedrockifierCLI for the actual backups: https://github.com/Kaiede/BedrockifierCLI
