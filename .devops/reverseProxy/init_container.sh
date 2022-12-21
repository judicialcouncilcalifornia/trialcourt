#!/bin/bash
echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel
[ -e "/home/site/nginx.conf" ] && cp "/home/site/nginx.conf" "/etc/nginx/nginx.conf"
cd /usr/bin/
supervisord -c /etc/supervisor/conf.d/supervisord.conf
