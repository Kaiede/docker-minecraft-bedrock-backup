# docker-minecraft-bedrock-backup

[![Docker Pulls](https://img.shields.io/docker/pulls/kaiede/minecraft-bedrock-backup.svg)](https://hub.docker.com/r/kaiede/minecraft-bedrock-backup)


Docker container for configuring backups of the itzg/minecraft-bedrock-server minecraft server.

This was built in part by understanding how itzg/mc-backup works, and is offered under similar license: https://github.com/itzg/docker-mc-backup 

Leverages BedrockifierCLI for the actual backups: https://github.com/Kaiede/BedrockifierCLI

### Features

- Makes snapshots of worlds in .mcworld format. Vanilla worlds can easily be imported to a client this way.
- Takes snapshots of all worlds in the server's worlds folder.
- Supports trimming backups to limit disk space usage.
- Properly handles taking snapshots while the server is running.

### Usage

The best way to configure this is to use a docker compose file along with the containers you wish to backup from. An example is under `Examples/docker-compose.yml`

For the service itself, it should be configured similarly to this:

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
      - /opt/bedrock/server:/bedrock_server
```

The key parts here are:
* The backup container should depend on the server containers, so that the server containers have a chance to fully start before any backups do.
* `BACKUP_INTERVAL` sets the timing on when to do backups. 
* Configuring the timezone is optional, but the container will use GMT if it isn't set, and timestamps/trimming of backups will not quite behave the way you expect otherwise.
* `/var/run/docker.sock` is required to be able to safely save server data. Keep it.
* `/opt/bedrock/backups` is where the world backups will be stored.
* `/opt/bedrock/server` in this example is the folder for the dedicated bedrock server. A named volume would work just as well, but makes restoring backups harder.

Using this example, `/opt/bedrock/backups` on the docker host will contain the world backups. It is recommended to use a non-root account for this folder, that is part of the docker group. So something like `myaccount:docker` should be the owner and group of the folder. This folder is used to know which UID/GID to use to demote, and without the correct user/group, the container won't be able to talk to the other containers properly. 

config.json for the above example will look like:

```
{
    "servers": {
        "bedrock_server": "/bedrock_server/worlds"
    },
    "trim": {
        "trimDays":   2,
        "keepDays":   14,
        "minKeep":    2
    }
}
```

The key parts here are telling the backup tool about the different servers, where to put backups, and information on the trim configuration. The servers list is in the format: `"container_name": "/path/to/worlds/folder"`

The above trim configuration will keep all backups from the last 2 days, and trim down to a single backup beyond that, deleting any backup older than 14 days. However, it will retain two copies of any specific world. This last feature is useful if you switch out worlds on a server, to avoid having it delete copies of worlds that aren't in use.

Put the config.json file in `/opt/bedrock/backups/config.json` if using the above example. Otherwise, it should live in the folder that is mapped to `/backups` in the container.

### Restoring Backups

Since the backups are stored as .mcworld files, it's straight-forward to stop the server container. Delete the world folder's contents, and then use unzip to unpack the backup into the now-empty world folder. Start the server container again, and you should have a restored server.

Currently, doing it from within the backup container is technically possible (`/opt/bedrock/BedrockifierCLI` has the ability to unpack mcworld files for you), but the server container shouldn't be running when restoring a backup, creating a bit of a catch 22. 
