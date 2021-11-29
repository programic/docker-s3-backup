#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Check if environment vars exists
: ${MYSQL_HOST?"You need to set the MYSQL_HOST environment variable."}
: ${MYSQL_USER?"You need to set the MYSQL_USER environment variable."}
: ${MYSQL_PASSWORD?"You need to set the MYSQL_PASSWORD environment variable."}
: ${MYSQL_DATABASE?"You need to set the MYSQL_DATABASE environment variable."}
: ${AWS_S3_BUCKET?"You need to set the AWS_S3_BUCKET environment variable."}
: ${AWS_ACCESS_KEY_ID?"You need to set the AWS_ACCESS_KEY_ID environment variable."}
: ${AWS_SECRET_ACCESS_KEY?"You need to set the AWS_SECRET_ACCESS_KEY environment variable."}
: ${AWS_DEFAULT_REGION?"You need to set the AWS_DEFAULT_REGION environment variable."}
: ${PINGBACK_URL?"You need to set the PINGBACK_URL environment variable."}
: ${PINGBACK_RETRY?"You need to set the PINGBACK_RETRY environment variable."}

backup_date=$(date +"%Y-%m-%dT%H:%M:%S%Z")

mysql_backup() {
  dump_file="mysql-backups/${backup_date}_${MYSQL_DATABASE}.sql.gz"

  # Backup single database
  mysqldump --host=${MYSQL_HOST} --port=${MYSQL_PORT:-3306} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} \
    --set-gtid-purged=OFF --triggers --routines --events --single-transaction --quick \
    --databases ${MYSQL_DATABASE} \
    | gzip > ${dump_file}

  # Upload backup to AWS S3
  aws s3 cp ${dump_file} s3://${AWS_S3_BUCKET}/${backup_date}/${MYSQL_DATABASE}.sql.gz

  if [[ $BACKUP_KEEP_LOCALLY != "true" ]]; then
    rm ${dump_file}
  fi
}

volume_backup() {
  # Loop all mounted volumes and backup files
  for volume in '/volume-backups/*'; do
    archive_file=$(mktemp)
    volume_basename=$(basename ${volume})

    tar -czf ${archive_file} ${volume}

    # Upload backup to AWS S3
    aws s3 mv ${archive_file} s3://${AWS_S3_BUCKET}/${backup_date}/${volume_basename}.tar
  done
}

send_pingback() {
  if [[ $PINGBACK_URL ]]; then
    curl --retry ${PINGBACK_RETRY} ${PINGBACK_URL}
  fi
}

mysql_backup
volume_backup
send_pingback