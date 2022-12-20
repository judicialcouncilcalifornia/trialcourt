FROM nginx:stable-alpine

# ssh
ENV SSH_PASSWD "root:Docker!"
ENV SSH_PORT 2222

# supervisor
ENV SUPERVISOR_LOG_DIR "/home/LogFiles/supervisor"

RUN apk add --no-cache openssh-server \
    && echo "$SSH_PASSWD" | chpasswd \
# =========
# Configure
# =========
# RUN set -ex\
	##
	&& rm -rf /var/log/nginx \
	&& ln -s $NGINX_LOG_DIR /var/log/nginx \
	##
	&& rm -rf /var/log/supervisor \
	&& ln -s $SUPERVISOR_LOG_DIR /var/log/supervisor \
      && apk update \
      && apk add --no-cache openssl git net-tools tcpdump tcptraceroute vim curl wget bash patch\
  	&& cd /usr/bin \
  	&& wget http://www.vdberg.org/~richard/tcpping \
  	&& chmod 777 tcpping
# ssh
COPY sshd_config /etc/ssh/
# Copy and configure the ssh_setup file
RUN mkdir -p /tmp
COPY ssh_setup.sh /tmp
RUN chmod +x /tmp/ssh_setup.sh \
    && (sleep 1;/tmp/ssh_setup.sh 2>&1 > /dev/null) \
    #---------------
    # openrc service
    #---------------
       && apk add --no-cache openrc \
       && sed -i 's/"cgroup_add_service/" # cgroup_add_service/g' /lib/rc/sh/openrc-run.sh

# supervisor
COPY supervisord.conf /etc/

COPY default.conf /etc/nginx/conf.d
COPY not-found.html /var/www/html/not-found.html

WORKDIR /usr/share/nginx/html

EXPOSE 2222 80

COPY init_container.sh /usr/local/bin/
RUN chmod -R +x /usr/local/bin
ENTRYPOINT ["init_container.sh"]
