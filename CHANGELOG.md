#### v1.1 - In Test
- Updated to Swift 5.5.2 compiler.
- Converted to a service instead of a script running a tool in a loop. This will enable new features in the future.
- Java containers can now be backed up, using the new `containers` settings in the configuration file.
- Configuration parsing now supports YAML format, and defaults to 'config.yml'. For compatibility, 'config.json' will be checked as a fallback.
- Configuration file now has a `schedule` section which replaces the environment variables. 
  - `interval` is the same as before. 
  - `daily` performs a single daily backup, mutually exclusive with `interval`.
  - `onPlayerLogin` performs a backup whenever a player logs in.
  - `onPlayerLogout` performs a backup whenever a player logs out.
  - `onLastLogout` performs a backup whenever the last player logs out.
  - `minInterval` throttles event/interval backups to a maximum of one during the minimum interval (i.e. 4h means one backup every 4h maximum). 
- Logging is now less verbose. There is a `loggingLevel` option in the configuration to make it verbose again for diagnostic purposes.

The following has been deprecated. They still currently work today, but are not expected to be supported at some point in the future.
- DEPRECATED: The "BACKUP_INTERVAL" environment variable is now part of the configuration file.
- DEPRECATED: The "servers" settings in the configuration file is now "containers" with support for Bedrock and Java.
- DEPRECATED: JSON configuration files have been deprecated in favor of YAML configuration files.

#### v1.0.3 - Dec 21st, 2021
- Updated to Swift 5.5 compiler.
- The property "tty: true" is no longer required on the server container.
- New "ownership" configuration for the backup allows changing the owner, group, and permissions on backups written. Changing the owner and group requires running as root, which isn't recommended. Trimming also may not work properly if the backup tool loses write access. Use with caution.

#### v1.0.2 - Dec 13th, 2021
- Container no longer exits when a backup fails, avoiding a restart loop.
- A running container will be marked unhealthy if backups are failing.

#### v1.0.1 Dec 1st, 2021
- Fixes for 1.18 servers that caused recurring backups.
