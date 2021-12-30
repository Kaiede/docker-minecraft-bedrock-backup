# Backup Tool Config File

```
containers:
  bedrock:
    - name: <container name>
      worlds:
        - <world path>
  java:
    - name: <container name>
      worlds:
        - <world path>
schedule:
  interval: <interval>
trim:
  trimDays: 2
  keepDays: 14
  minKeep: 2
loggingLevel: [debug or trace]
ownership:
  chown: 1000:1001
  permissions: 644
```

### Containers

This section lists all the servers to be backed up, and informs the tool how to talk to docker, and where to find the worlds. It is split into `bedrock` and `java`. Put Bedrock servers under `bedrock` and Java servers under `java` and it will properly back each type up in the correct way.

* `<container name>`: This is the name of the docker container to be backed up. Something like `minecraft_server` as an example. It needs to match the name visible in `docker ps`, or the `container_name` setting in docker-compose.yml. 

* `<world path>`: This is the internal path to the world folder you want to backup. For example, if you mapped `/opt/bedrock/server` to `/server` in your `docker-compose.yml`, then this path should be `/server/worlds/<MyWorldName>`

### Schedule

* `interval`: This is the timing on backups, specified in hours, minutes, or seconds. So you can use values like: `600s`, `60m` or `3h` to set how often the backup is kicked off. 

### Trim

Trimming backups allows you control how much disk space is used by backups by deleting old backups, and only keeping daily backups after a certain number of days.

It is controlled by the following settings:

* `keepDays`: This is how many days of backups to keep. Setting this to 14 days means no backups after 14 days are kept, unless kept by minKeep.

* `trimDays`: How many days to keep of backups before trimming them down. Setting this to 2 days, with a 3 hour backup interval means that for the last 2 days, you'll keep all the 3 hour backups. After 2 days, the backups will get trimmed down to just a single daily backup, up to the keepDays limit. 

* `minKeep`: A minimum number of backups to keep. This is useful if you switch worlds on your server, as it will make sure you always have a couple backups of any world even if it hasn't been used in a while. This will override keepDays, and let you keep at least this many backups indefinitely.

### Logging Level

* `loggingLevel`: This can be set to `debug` or `trace` to enable extra logging for diagnostic purposes. In most cases, it's fine to leave it out of your config file unless reporting a bug. 

### Ownership

This is meant for the rare cases where files on disk need to be a very specific user and group, and/or have specific permissions. NAS devices being one example. It allows you to tell the service how to set ownership and permissions on the backups written to disk.

This functionality may break trimming of backups if it causes the service to no longer be able to have write permissions to the backups. Use with caution.

* `chown`: This sets the owner and group on backed up mcworld files. It works much like the `chown` command's argument, but only accepts ids, not names. **Using this requires the service to run as root which is not recommended.**

* `permissions`: Sets unix permissions for the backed up files. This is the standard POSIX bitmask in string form. 
