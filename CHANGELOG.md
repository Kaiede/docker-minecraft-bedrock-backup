- Updated to Swift 5.5 compiler.
- The property "tty: true" is no longer required on the server container.

#### v1.0.2 - Dec 13th, 2021
- Container no longer exits when a backup fails, avoiding a restart loop.
- A running container will be marked unhealthy if backups are failing.

#### Dec 1st, 2021
- Fixes for 1.18 servers that caused recurring backups.
