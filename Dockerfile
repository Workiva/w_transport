FROM drydock-prod.workiva.net/workiva/dart2_base_image:1

ARG GIT_SSH_KEY
ARG KNOWN_HOSTS_CONTENT


RUN mkdir /root/.ssh
RUN echo "$KNOWN_HOSTS_CONTENT" > "/root/.ssh/known_hosts"
RUN chmod 700 /root/.ssh/
RUN umask 0077 && echo "$GIT_SSH_KEY" >/root/.ssh/id_rsa
RUN eval "$(ssh-agent -s)" && ssh-add /root/.ssh/id_rsa

WORKDIR /build/
ADD . /build/
RUN dart pub get
FROM scratch
