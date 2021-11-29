FROM alpine:3.15

COPY scripts /

RUN apk add --no-cache bash mysql-client python3 py-pip \
    && pip install awscli \
    && chmod a+x /*.sh \
    && mkdir -p /mysql-backups /volume-backups

CMD ["/set-crontab.sh"]