FROM debian:latest

ARG UID=1000
ARG GID=1000

RUN apt update && apt install -y make bash-completion iptables sudo git \
    && groupadd -g${GID} sipfw \
    && useradd -s /bin/bash -u ${UID} -g ${GID} -m -d /app sipfw 

COPY --chown=0:0 docker/90-sipfw /etc/sudoers.d/90-sipfw

WORKDIR /app

COPY --chown=${UID}:${GID} . /app/sipfw

RUN cd /app/sipfw && make

USER sipfw

CMD ["sleep", "infinity"]