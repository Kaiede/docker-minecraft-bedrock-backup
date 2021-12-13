# docker-minecraft-bedrock-backup

[![Docker Pulls](https://img.shields.io/docker/pulls/kaiede/minecraft-bedrock-backup.svg)](https://hub.docker.com/r/kaiede/minecraft-bedrock-backup)
[![GitHub Issues](https://img.shields.io/github/issues-raw/kaiede/minecraft-bedrock-backup.svg)](https://github.com/kaiede/minecraft-bedrock-backup/issues)
[![Build](https://github.com/itzg/docker-minecraft-bedrock-server/workflows/Build/badge.svg)](https://github.com/kaiede/minecraft-bedrock-backup/actions?query=workflow%3ABuild)

Docker container for configuring backups of the itzg/minecraft-bedrock-server minecraft server.

This was built in part by understanding how itzg/mc-backup works, and is offered under similar license: https://github.com/itzg/docker-mc-backup 

Leverages BedrockifierCLI for the actual backups: https://github.com/Kaiede/BedrockifierCLI

### Features

- Makes snapshots of worlds in .mcworld format. Vanilla worlds can easily be imported to a client this way.
- Takes snapshots of all worlds in the server's worlds folder.
- Supports trimming backups to limit disk space usage.
- Properly handles taking snapshots while the server is running.

### Usage

There's a couple of steps required to properly configure this service, since it integrates with both docker and the minecraft server containers you are running. You can find a full example of the configuration files in the `Examples` folder on GitHub. 

* [Note File Locations](#note-file-locations)
* [Setup docker-compose.yml](#configure-docker-compose-file)
* [Setup config.json](#configure-backup-service)
* [Run](#run)

### Note File Locations

Backups require access to three locations. Make a note of these. 

* Your `docker.sock` file. 
  * When docker is run as root, this will be `/var/run/docker.dock` usually. When run rootless, you will need to look this up for yourself, but can usually be found by running `echo $DOCKER_HOST`, and should look something like `/run/user/1000/docker.sock`.
* Your bedrock server folder. 
  * This will either be a named volume, or a folder on the host. As an example, we will be using `/opt/bedrock/server`.
  * More details are available 
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
    name: bedrock_backup
    restart: always
    depends_on:
      - "bedrock_server"
    environment:
      BACKUP_INTERVAL: "3h"
      TZ: "America/Los_Angeles"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/bedrock/backups:/backups
      - /opt/bedrock/server:/server
```

The service should always depend on all the bedrock servers listed in your `docker-compose.yml` file. We want to let the minecraft servers start before taking a backup on launch. It is recommended to set `container_name` for each server that will be backed up as docker-compose will assign one automatically if it isn’t set, and this simplifies configuring the backup service. 

For the volumes, we need to configure them this way:
* Map in `docker.sock`. The above example should work fine for when docker runs as root. When running rootless, take the value you found earlier and include it like so: `/run/user/1000/docker.sock:/var/run/docker.sock`
* Map in your backups folder. In our example, we put it at `/opt/bedrock/backups` on our host. It should always be mapped into `/backups` in the container.
* Map in each server folder. Our example has one server, so we map one folder in. You can place it anywhere inside the container, as we will reference it later in the service configuration file. 

Looking at the environment variables, there are a few settings that can be configured here:
* `BACKUP_INTERVAL`: This configures how often the backups are run. In this example, it is every 3 hours.
* `TZ`: This sets the timezone. It is optional, but it will use GMT if not set.
* `UID` and `GID`: Use these when the automatic demotion doesn't work for you. They aren't necessary when running rootless. 
* `DATA_DIR`: Use this when you want to change the location of the `/backups` directory to something different within the container. The main reason you might want to do that is if you are using a named volume for backups from multiple sources, and want your minecraft backups to live in a subfolder of that volume. 

### Configure Backup Service

Inside your backups folder, you will need to create a `config.json` file. It looks like this:

```
{
    "servers": {
        "bedrock_server": "/server/worlds"
    },
    "trim": {
        "trimDays":   2,
        "keepDays":   14,
        "minKeep":    2
    }
}
```

Each item under `servers` has the container name, and path to the worlds folder as it appears inside the backup container. The container name must match the one in your `docker-compose.yml` file. For the worlds folder path, in our example we mapped `/opt/bedrock/server` to `/server`, and with the worlds folder at `/opt/bedrock/server/worlds` we should set `/server/worlds` in the json file.

The trim settings have three values:

* `keepDays`: This is how many days of backups to keep. 14 in the example above means we will keep 14 days worth of backups.
* `trimDays`: How many days to keep of backups before trimming them down. In this example, the last two days will always have all backups available. But past 2 days (and up to the keep limit), it will trim down to a single backup per day, the last one before midnight. 
* `minKeep`: A minimum number of backups to keep. This is useful if you switch worlds on your server, as it will make sure you always have a couple backups of any world even if it hasn't been used in a while, and will keep backups past the `keepDays` value.

### Run

Run `docker-compose up` once the above steps are done to verify via the console that the first backup is successful. Then you can stop the containers and restart them using `docker-compose start` to run them in the background like you normally would. 

### Restoring Backups

Since the backups are stored as .mcworld files, it also happens to be a zip file. Using the above example, if my world is called "MyWorld", then my restoration looks a bit like this:

* `docker-compose stop`
* `cd /opt/bedrock/server/worlds/MyWorld`
* `rm -rf *`
* `unzip /opt/bedrock/backups/MyWorld-<TIMESTAMP>.mcworld`

The tool that runs the backups `BedrockifierCLI` can also pack/unpack worlds a bit more easily, but at the moment, running it from the docker container is a bit of a catch-22 if you made the container dependent on the servers. You don't want the servers to be running when you restore a backup, and the backup container depends on the servers so it can make backups.
