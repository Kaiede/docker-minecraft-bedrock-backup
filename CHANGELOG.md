#### In 'test'
- Updated to Swift 5.5 compiler.
- The property "tty: true" is no longer required on the server container.
- New "ownership" configuration for the backup allows changing the owner, group, and permissions on backups written. Changing the owner and group requires running as root, which isn't recommended. Trimming also may not work properly if the backup tool loses write access. Use with caution.

#### v1.0.2 - Dec 13th, 2021
- Container no longer exits when a backup fails, avoiding a restart loop.
- A running container will be marked unhealthy if backups are failing.

#### v1.0.1 Dec 1st, 2021
- Fixes for 1.18 servers that caused recurring backups.
