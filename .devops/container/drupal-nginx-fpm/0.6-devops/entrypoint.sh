#!/bin/bash

# set -e

php -v

DEPLOYMENT_DIR="/home/deployment"
DEPLOYMENT_TAG="$DEPLOYMENT_DIR/tag.txt"

post_deployment_tasks(){
  cat $DRUPAL_SOURCE/tag.txt > $DEPLOYMENT_TAG
  cd "$DRUPAL_PRJ/web/sites/$SITE_MAP_ID"

  echo "RUNNING POST DEPLOYMENT TASKS..."
  echo "Clear cache"
  drush cr
  echo "Update database"
  drush updb -y
  echo "Import config"
  drush cim -y
  echo "Import features"
  drush fra --bundle=jcc_tc2 -y
  echo "Clear cache again"
  drush cr
}

#Get drupal from Git
setup_drupal(){
  while test -d "$DRUPAL_PRJ"
  do
    echo "INFO: $DRUPAL_PRJ exists, clean it..."
    # mv is faster than rm.
    mv $DRUPAL_PRJ /tmp/drupal_prj_bak$(date +%s)
  done

  test ! -d "$DRUPAL_PRJ" && echo "INFO: $DRUPAL_PRJ not found. Creating..." && mkdir -p "$DRUPAL_PRJ"
	cd $DRUPAL_PRJ

  if [ "$(ls -A $DRUPAL_BUILD)" ]
  then
    echo "COPYING FILES FROM $DRUPAL_BUILD TO $DRUPAL_PRJ"
    cp -R $DRUPAL_BUILD/* $DRUPAL_PRJ/
    echo "All files copied."
  else
    	echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"
    	echo "REPO: "$GIT_REPO
    	echo "BRANCH: "$GIT_BRANCH
    	echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"

      echo "INFO: Clone from "$GIT_REPO
      git clone ${GIT_REPO} --branch ${GIT_BRANCH} $DRUPAL_PRJ	&& cd $DRUPAL_PRJ
      rm -rf $DRUPAL_PRJ/.git

      composer install --no-interaction --prefer-dist
      scripts/theme.sh -i jcc_base && scripts/theme.sh -b jcc_base
      scripts/theme.sh -i jcc_deprep && scripts/theme.sh -b jcc_deprep
      scripts/theme.sh -i jcc_newsroom && scripts/theme.sh -b jcc_newsroom
  fi

  while test -d "$DRUPAL_HOME"
  do
      echo "INFO: $DRUPAL_HOME exists. Clean it ..."
      chmod 777 -R $DRUPAL_HOME
      rm -Rf $DRUPAL_HOME
  done
  ln -s $DRUPAL_PRJ/web $DRUPAL_HOME

  # Persist drupal/sites
  chmod a+w "$DRUPAL_PRJ/web/sites/default"
  if [ -d "$DRUPAL_STORAGE" ]
  then
    rm -rf $DRUPAL_PRJ/web/sites/default/files
    ln -s $DRUPAL_STORAGE $DRUPAL_PRJ/web/sites/default/files
  else
      echo "ERROR: Directory $DRUPAL_STORAGE is not mounted."
  fi
}

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

# setup Drupal
if [ -e "$DRUPAL_HOME/web/sites/default/settings.php" ] || [ "$RESET_INSTANCE" == "true" ];then
# Site exists.
    if [ -d "$DRUPAL_PRJ" ]; then
        echo "INFO: $DRUPAL_PRJ exists..."
        echo "INFO: Site is Ready..."
    else
        echo "INSTALLING DRUPAL..."
        setup_drupal
    fi
else
# drupal isn't installed, fresh start
    echo "INSTALLING DRUPAL..."
    setup_drupal
fi

# Tell code to use Azure Settings for all sites
echo "UPDATING SETTINGS.LOCAL.PHP..."
find $DRUPAL_PRJ/web/sites -maxdepth 1 -mindepth 1 -type d | while read dir; do
  SITE_ID=$(basename $dir)

  test -d "$dir/settings.local.php" && chmod a+w "$dir/settings.local.php" && rm "$dir/settings.local.php"
  cp "$DRUPAL_SOURCE/settings.local.php" "$dir/settings.local.php"
  chmod a-w "$dir/settings.php"
  chmod a-w "$dir/settings.local.php"
done

# Check if config-import and cache clear are needed
test ! -d "$DEPLOYMENT_DIR" && echo "INFO: $DEPLOYMENT_DIR not found. creating ..." && mkdir -p "$DEPLOYMENT_DIR"
if [ -f "$DEPLOYMENT_TAG" ]; then
  TAG=$(cat $DEPLOYMENT_TAG)
  BUILD_TAG=$(cat $DRUPAL_SOURCE/tag.txt)
  if [ "$TAG" != "$BUILD_TAG"  ]; then
    echo "NEW BUILD DETECTED.  RUNNING POST DEPLOYMENT TASKS."
    post_deployment_tasks
  else
    echo "SAME BUILD DETECTED.  SKIPPING DEPLOYMENT TASKS."
  fi
else
  echo "NEW BUILD DETECTED.  RUNNING POST DEPLOYMENT TASKS."
  post_deployment_tasks
fi

# Create log folders
test ! -d "$SUPERVISOR_LOG_DIR" && echo "INFO: $SUPERVISOR_LOG_DIR not found. creating ..." && mkdir -p "$SUPERVISOR_LOG_DIR"
test ! -d "$VARNISH_LOG_DIR" && echo "INFO: Log folder for varnish found. creating..." && mkdir -p "$VARNISH_LOG_DIR"
test ! -d "$NGINX_LOG_DIR" && echo "INFO: Log folder for nginx/php not found. creating..." && mkdir -p "$NGINX_LOG_DIR"
test ! -e /home/50x.html && echo "INFO: 50x file not found. creating..." && cp /usr/share/nginx/html/50x.html /home/50x.html
# Backup default nginx setting, use customer's nginx setting
test -d "/home/etc/nginx" && mv /etc/nginx /etc/nginx-bak && ln -s /home/etc/nginx /etc/nginx
test ! -d "/home/etc/nginx" && mkdir -p /home/etc && mv /etc/nginx /home/etc/nginx && ln -s /home/etc/nginx /etc/nginx
# Backup default varnish setting, use customer's nginx setting
test -d "/home/etc/varnish" && mv /etc/varnish /etc/varnish-bak && ln -s /home/etc/varnish /etc/varnish
test ! -d "/home/etc/varnish" && mkdir -p /home/etc && mv /etc/varnish /home/etc/varnish && ln -s /home/etc/varnish /etc/varnish

if [ "$ENABLE_VARNISH" == "true" ];then
  echo "STARTING VARNISHD..."
  /usr/sbin/varnishd -a :80 -f /etc/varnish/default.vcl
  sed -i 's|listen 80;|listen 8080;|g' /home/etc/nginx/nginx.conf
  sed -i 's|listen [::]:80;|listen [::]:8080;|g' /home/etc/nginx/nginx.conf
fi

echo "INFO: creating /run/php/php-fpm.sock..."
test -e /run/php/php-fpm.sock && rm -f /run/php/php-fpm.sock
mkdir -p /run/php && touch /run/php/php-fpm.sock && chown nginx:nginx /run/php/php-fpm.sock && chmod 777 /run/php/php-fpm.sock

sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config

# Get environment variables to show up in SSH session
eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

echo "STARTING SSH..."
echo "STARTING PHP-FPM..."
echo "STARTING NGINX..."

cd /usr/bin/
supervisord -c /etc/supervisord.conf
