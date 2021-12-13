# Configuring Permissions

Permissions in simple cases can be handled automatically, but in many cases, there is a need for users to configure the permissions manually.

### Default Behavior

The service uses a tool called `entrypoint-demoter` to avoid running the service as root. By default it will automatically demote the service to the user and group that owns your backups directory.

In many cases you can use a regular user that has been added to the docker group. This is how I setup my personal server on a virtual machine. It makes things easier when you want to restore backups or otherwise manage the backups manually. 

### Overriding User/Group of the Backup Tool

In cases where you need to override the user and group that is picked for you by `entrypoint-demoter`. The user must be part of the docker group, or otherwise have access to attach to the server containers. This also will have problems when running Docker rootless. To do the override, set the `UID` and `GID` environment variables in your `docker-compose.yml` file.

### Overriding Permissions on Backed Up Worlds

In the `config.json`, there is an **EXPERIMENTAL** feature that allows you to override the user, group, and permissions for the backups. It is only recommended to do this if you absolutely have to, such as running it on a NAS device that requires specific ownership and permissions.

**Using chown requires running the service as root which is not recommended!**

```
  ...
  "ownership": {
    "chown": "<uid>:<gid>",
    "permissions": "644"
  }
  ...
```
