#!/bin/bash

# set -e

php -v

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

# setup Drupal
echo "DEPLOYING SITE..."

if [ ! -d "$DRUPAL_BUILD" ] || [ "$RESET_INSTANCE" == "true" ];then
  echo "FRESH DRUPAL INSTALLATION..."
  mkdir -p ${DRUPAL_BUILD}

  GIT_REPO=${GIT_REPO:-https://github.com/judicialcouncilcalifornia/trialcourt.git}
  GIT_BRANCH=${GIT_BRANCH:-master}
  echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"
  echo "REPO: "$GIT_REPO
  echo "BRANCH: "$GIT_BRANCH
  echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"

  echo "INFO: Clone from "$GIT_REPO
  git clone ${GIT_REPO} --branch ${GIT_BRANCH} repobuild
  rm -rf repobuild/.git
  cp -R repobuild/* ${DRUPAL_BUILD}/
  rm -rf repobuild

  cd ${DRUPAL_BUILD}
  composer install
  scripts/theme.sh -i jcc_base && scripts/theme.sh -b jcc_base
  scripts/theme.sh -i jcc_deprep && scripts/theme.sh -b jcc_deprep
  scripts/theme.sh -i jcc_newsroom && scripts/theme.sh -b jcc_newsroom
fi

WWW_ROOT=$DRUPAL_PRJ/$WWW_SUBDIR
test -d "$DRUPAL_PRJ" && echo "Removing $DRUPAL_PRJ" && find "$DRUPAL_PRJ" -print0 | xargs -0 rm -rf
echo "Creating $DRUPAL_PRJ" && mkdir -p "$DRUPAL_PRJ"
cd $DRUPAL_PRJ
echo "Copying files from $DRUPAL_BUILD to $DRUPAL_PRJ" && cp -R $DRUPAL_BUILD/* $DRUPAL_PRJ

test ! -d "$DRUPAL_PRJ/web/sites/default/files" && mkdir -p "$DRUPAL_PRJ/web/sites/default/files"
chmod a+w "$DRUPAL_PRJ/web/sites/default"
chmod a+w "$DRUPAL_PRJ/web/sites/default/files"

# Tell code to use Azure Settings for all sites
find $DRUPAL_PRJ/web/sites -maxdepth 1 -mindepth 1 -type d | while read dir; do
  SITE_ID=$(basename $dir)

  test -d "$dir/settings.local.php" && chmod a+w "$dir/settings.local.php" && rm "$dir/settings.local.php"
  cp "$DRUPAL_BUILD/settings.local.php" "$dir/settings.local.php"
  chmod a-w "$dir/settings.php"
  chmod a-w "$dir/settings.local.php"
done

# Persist drupal/sites
if [ -d "$DRUPAL_STORAGE" ]
then
  test ! -d "$DRUPAL_STORAGE/files" && mkdir -p "$DRUPAL_STORAGE/files"
  ln -s $DRUPAL_STORAGE/files $DRUPAL_PRJ/web/sites/default/files
else
    echo "Error: Directory $DRUPAL_STORAGE is not mounted."
fi

# Create log folders
test ! -d "$SUPERVISOR_LOG_DIR" && echo "INFO: $SUPERVISOR_LOG_DIR not found. creating ..." && mkdir -p "$SUPERVISOR_LOG_DIR"
test ! -d "$VARNISH_LOG_DIR" && echo "INFO: Log folder for varnish found. creating..." && mkdir -p "$VARNISH_LOG_DIR"
test ! -d "$NGINX_LOG_DIR" && echo "INFO: Log folder for nginx/php not found. creating..." && mkdir -p "$NGINX_LOG_DIR"
test ! -e /home/50x.html && echo "INFO: 50x file not found. createing..." && cp /usr/share/nginx/html/50x.html /home/50x.html
# Backup default nginx setting, use customer's nginx setting
test -d "/home/etc/nginx" && mv /etc/nginx /etc/nginx-bak && ln -s /home/etc/nginx /etc/nginx
test ! -d "/home/etc/nginx" && mkdir -p /home/etc && mv /etc/nginx /home/etc/nginx && ln -s /home/etc/nginx /etc/nginx
# Backup default varnish setting, use customer's nginx setting
test -d "/home/etc/varnish" && mv /etc/varnish /etc/varnish-bak && ln -s /home/etc/varnish /etc/varnish
test ! -d "/home/etc/varnish" && mkdir -p /home/etc && mv /etc/varnish /home/etc/varnish && ln -s /home/etc/varnish /etc/varnish

#echo "Starting Varnishd ..."
if [ "$ENABLE_VARNISH" == "true" ];then
  /usr/sbin/varnishd -a :80 -f /etc/varnish/default.vcl
  sed -i 's|listen 80;|listen 8080;|g' /home/etc/nginx/nginx.conf
  sed -i 's|listen [::]:80;|listen [::]:8080;|g' /home/etc/nginx/nginx.conf
fi

# Set WWW root
sed -i "s|WWW_ROOT|$WWW_ROOT|g" /home/etc/nginx/nginx.conf

if [ "$HTML_ONLY" == "true" ];then
  sed -i 's|try_files $uri /index.php?$query_string;|try_files $uri /index.html;|g' /home/etc/nginx/nginx.conf
fi

echo "INFO: creating /run/php/php-fpm.sock ..."
test -e /run/php/php7.4-fpm.sock && rm -f /run/php/php7.4-fpm.sock
mkdir -p /run/php && touch /run/php/php7.4-fpm.sock && chown nginx:nginx /run/php/php7.4-fpm.sock && chmod 777 /run/php/php7.4-fpm.sock

sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config

# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " "\""$1"\"""=""\""$2"\"" }' >> /etc/profile)

echo "Starting SSH ..."
echo "Starting php-fpm ..."
echo "Starting Nginx ..."

cd /usr/bin/
supervisord -c /etc/supervisord.conf
