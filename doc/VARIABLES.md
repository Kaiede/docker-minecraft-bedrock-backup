# Configuration Variables

Below is a full list of variables that can be provided as environment variables in the `docker-compose.yml` file to the backup container.

### Core Variables

* `BACKUP_INTERVAL`: This configures how often the backups are run. In this example, it is every 3 hours.
* `TZ`: This sets the timezone. It is optional, but it will use GMT if not set.

### Security/Permissions Variables

* `UID`: User to run the backup as, overriding the owner of the `/backups` folder.
* `GID`: Group to run the backup as, overriding the group of the `/backups` folder.

### Optional Variables

* `CONFIG_FILE`: Use this in the rare case that you want to use something other than `config.json` as the file name of your backup configuration. 
* `DATA_DIR`: Use this when you want to change the location of the `/backups` directory to something different within the container. The main reason you might want to do that is if you are using a named volume for backups from multiple sources, and want your minecraft backups to live in a subfolder of that volume. 

