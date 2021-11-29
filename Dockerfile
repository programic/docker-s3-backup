FROM alpine:3.15

RUN apk add --no-cache bash mysql-client python3 py-pip \
    && pip install awscli \
    && mkdir -p /mysql-backups /volume-backups

COPY scripts /

RUN chmod a+x /*.sh

CMD ["/set-crontab.sh"]