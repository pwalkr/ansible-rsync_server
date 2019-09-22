FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install --no-install-recommends --yes \
    openssh-server \
    python

RUN apt-get install --no-install-recommends --yes rsync ansible

COPY start.sh /usr/local/bin
ENTRYPOINT /usr/local/bin/start.sh

RUN mkdir /root/.ssh && chmod 700 /root/.ssh

ARG id_rsa
RUN test -z "$id_rsa" || ( \
    echo "$id_rsa" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa \
)

ARG authorized_keys
RUN test -z "$authorized_keys" || ( \
    echo "$authorized_keys" > /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys \
)
