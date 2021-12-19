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
: "${CONFIG_FILE:=config.yaml}"
: "${BACKUP_INTERVAL:=${INTERVAL_SEC:-24h}}"

# TODO: Handle backwards compat here looking for a config.json and/or yaml by default.

# Fire backup via BedrockifierCLI Tool
#/opt/bedrock/bedrockifiertool backupjob "${DATA_DIR}/${CONFIG_FILE}" --dockerPath "${DOCKER_PATH}" --backupPath "${DATA_DIR}" >&2
/opt/bedrock/bedrockifierd "${DATA_DIR}/${CONFIG_FILE}" --dockerPath "${DOCKER_PATH}" --backupPath "${DATA_DIR}" >&2
