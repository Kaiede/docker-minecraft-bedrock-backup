#!/bin/bash
#
# Backup Job Entrypoint
#
# Used by the docker container

set -uo pipefail

# Configure extra logging
LOGGING_ARGS=""
case "${LOGGING:-normal}" in
  "trace")
    LOGGING_ARGS="--trace"
    set -x
    ;;

  "debug")
    LOGGING_ARGS="--debug"
    set -x
    ;;
esac

# Configure arguments for service
DOCKER_PATH="/usr/bin/docker"
: "${BACKUP_INTERVAL:=${INTERVAL_SEC:-24h}}"
: "${DATA_DIR:=/backups}"
: "${CONFIG_FILE:=config.yml}"

# Check for new config file first, but fall back
# onto the old default if it doesn't exist.
if [ ! -e "${DATA_DIR}/${CONFIG_FILE}" ]; then
  echo "WARN[0000] ${CONFIG_FILE} not found, falling back to config.json"
  CONFIG_FILE="config.json"
fi

# Fire backup via BedrockifierCLI Tool
echo RUN [0000] /opt/bedrock/bedrockifierd "${DATA_DIR}/${CONFIG_FILE}" --docker-path "${DOCKER_PATH}" --backup-path "${DATA_DIR}" ${LOGGING_ARGS}
/opt/bedrock/bedrockifierd "${DATA_DIR}/${CONFIG_FILE}" --docker-path "${DOCKER_PATH}" --backup-path "${DATA_DIR}" ${LOGGING_ARGS} >&2
