#!/bin/bash
#
# Backup Job Entrypoint
#
# Used by the docker container

set -euo pipefail

if [ "${DEBUG:-false}" == "true" ]; then
  set -x
fi

: "${DOCKER_PATH:=/usr/bin/docker}"
: "${DATA_DIR:=/backups}"
: "${CONFIG_FILE:=config.json}"
: "${BACKUP_INTERVAL:=${INTERVAL_SEC:-24h}}"

while true; do
  # Fire backup via BedrockifierCLI Tool
  /opt/bedrock/BedrockifierCLI backupjob "${DATA_DIR}/${CONFIG_FILE}" --dockerPath "${DOCKER_PATH}" --backupPath "${DATA_DIR}" >&2

  # If BACKUP_INTERVAL is not a valid number (i.e. 24h), we want to sleep.
  # Only raw numeric value <= 0 will break
  if (( BACKUP_INTERVAL <= 0 )) &>/dev/null; then
    break
  else
    echo "[INFO] sleeping ${BACKUP_INTERVAL}..."
    # shellcheck disable=SC2086
    sleep ${BACKUP_INTERVAL}
  fi
done
