# docker-minecraft-bedrock-backup

[![Docker Pulls](https://img.shields.io/docker/pulls/kaiede/minecraft-bedrock-backup.svg)](https://hub.docker.com/r/kaiede/minecraft-bedrock-backup)
[![GitHub Issues](https://img.shields.io/github/issues-raw/kaiede/docker-minecraft-bedrock-backup.svg)](https://github.com/kaiede/docker-minecraft-bedrock-backup/issues)
[![Build](https://github.com/kaiede/docker-minecraft-bedrock-backup/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/kaiede/docker-minecraft-bedrock-backup/actions?query=workflow%3A%22Docker+Image+CI%22)

Docker container for configuring backups of the Minecraft [Bedrock](https://hub.docker.com/r/itzg/minecraft-bedrock-server) and [Java](https://hub.docker.com/r/itzg/minecraft-server) docker containers provided by itzg.

### Features

- Bedrock backups use the .mcworld format, meaning Vanilla worlds can be imported using any Bedrock client.
- Java backups use the same .zip backup format as the game client, making them easier to work with.
- Takes snapshots while the server is running.
- Supports trimming backups to limit disk space usage.

### Usage

Detailed instructions are in the [Wiki](https://github.com/Kaiede/docker-minecraft-bedrock-backup/wiki).

### Release Notes

Release Notes are available on [GitHub](https://github.com/Kaiede/docker-minecraft-bedrock-backup/releases), along with a full [Changelog](https://github.com/Kaiede/docker-minecraft-bedrock-backup/blob/main/CHANGELOG.md) which includes changes in testing. 

### Credits

This was built in part by understanding how itzg/mc-backup works for Java, and is offered under similar license: https://github.com/itzg/docker-mc-backup 

Leverages BedrockifierCLI for the actual backups: https://github.com/Kaiede/BedrockifierCLI
