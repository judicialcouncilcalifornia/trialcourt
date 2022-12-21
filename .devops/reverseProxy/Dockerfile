FROM nginx:latest

# ssh
ENV SSH_PASSWD "root:Docker!"
ENV SSH_PORT 2222
# supervisor
ENV SUPERVISOR_LOG_DIR "/home/LogFiles/supervisor"

# Install openssh-server to provide web ssh access from kudu, supervisor to run processor
RUN apt-get clean && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    supervisor \
    openssh-server \
    && echo "root:Docker!" | chpasswd

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY sshd_config /etc/ssh/
COPY init_container.sh /bin/
COPY index.html /home/site/wwwroot/index.html

EXPOSE 80 2222
CMD ["/bin/init_container.sh"]
