# Base Dockerfile: https://github.com/mesosphere/aws-cli/blob/master/Dockerfile
FROM alpine:3.6
RUN apk -v --update add \
        python \
        py-pip \
        groff \
        less \
        mailcap \
        && \
    pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*
RUN apk -v --update add mysql-client
COPY command.sh /command.sh
ENTRYPOINT ["/bin/sh", "/command.sh"]
