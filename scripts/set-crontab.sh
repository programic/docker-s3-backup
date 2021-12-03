#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

: ${SCHEDULE?"You need to set the SCHEDULE environment variable."}

if [[ $BACKUP_ON != "true" ]]; then
    exit 0
fi

# Set crontab
echo "${SCHEDULE} cd / && ./backup.sh >> /dev/null 2>&1 \n#" | crontab -

# Run crontab on foreground
crond -f