# Restoring Backups

The backups are stored as .mcworld files, which also happen to be zip files. It makes it possible to restore a backup doing something like this:

* `docker-compose stop`
* `cd /opt/bedrock/server/worlds`
* `mv MyWorld MyWorld.bak`
* `mkdir MyWorld`
* `cd MyWorld`
* `unzip /opt/bedrock/backups/MyWorld-<TIMESTAMP>.mcworld`
* `docker-compose start`
* Delete MyWorld.bak once everything is confirmed working

In this example, `/opt/bedrock/server` is the data folder for the minecraft server container, and `/opt/bedrock/backups` is the backup folder for the backup container. 

### Future Improvements

`BedrockifierCLI` can also pack and unpack worlds quite easily. At the moment running it from the docker container is a catch-22 if the backup container is dependent on the server containers. You don't want the server to be running when restoring a backup, but the backup container depends on the servers so it can make the backup.

A future improvement here would be to figure out a process to make the restoration process less manual.
