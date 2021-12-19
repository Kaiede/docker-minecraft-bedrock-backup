#!/bin/bash
#
# Backup Job Entrypoint
#
# Used by the docker container

set -uo pipefail

if [ "${DEBUG:-false}" == "true" ]; then
  set -x
fi

: "${DOCKER_PATH:=/usr/bin/docker}"
: "${DATA_DIR:=/backups}"
: "${CONFIG_FILE:=config.yml}"
: "${BACKUP_INTERVAL:=${INTERVAL_SEC:-24h}}"

# TODO: Handle backwards compat here looking for a config.json and/or yaml by default.

# Fire backup via BedrockifierCLI Tool
/opt/bedrock/bedrockifierd "${DATA_DIR}/${CONFIG_FILE}" --docker-path "${DOCKER_PATH}" --backup-path "${DATA_DIR}" >&2
