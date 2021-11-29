# Example Docker compose file
This is an example Docker compose file showing how to use the s3 backup.

```yaml
version: '3.8'
services:

  app:
    image: my-project/my-image:latest
    volumes:
      - storage-data:/var/www/storage/
    networks:
      - network

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: "secret" # Default user is root
      MYSQL_DATABASE: "default"
    networks:
      - network

  s3-backup:
    image: programic/s3-backup
    environment:
      BACKUP_ON: true
      BACKUP_KEEP_LOCALLY: false
      SCHEDULE: "0 */4 * * *"
      MYSQL_HOST: "mysql" # Name of MySQL service
      MYSQL_DATABASE: "default"
      MYSQL_USER: "root"
      MYSQL_PASSWORD: "secret"
      AWS_ACCESS_KEY_ID: "[access-key-id-here]"
      AWS_SECRET_ACCESS_KEY: "[secret-access-key-here]"
      AWS_DEFAULT_REGION: "[region-here]"
      AWS_S3_BUCKET: "[bucket-here]" # E.g. my-bucket/my-folder/my-sub-folder
    volumes:
      - storage-data:/volume-backups/storage/
    networks:
      - network

volumes:
  storage-data:

networks:
  network:
```

## Mysql privileges
In order to backup the database, the backup user needs the following privileges.

```mysql
GRANT SELECT, TRIGGER, EVENT ON *.* TO `backup_user`@`%`;
```