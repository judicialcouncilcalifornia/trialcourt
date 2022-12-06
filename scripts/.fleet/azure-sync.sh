#!/usr/bin/env bash

show_help() {
  name="azure-sync"
  description="Grab db and files from Pantheon and import them to Azure."
  usage="scripts/fleet azure-sync [env] [element] [directory]"
  # Use this exact template in all show_help functions for consistentency.
  . ${BASEDIR}/scripts/.fleet/templates/show_help.sh
}

do_command() {
  PIDS=""
  declare -a sitemap

  rm -rf ${dir}
  mkdir -p ${dir}

  for site in $sites
    do
      site="jcc-${site}.${env}"
      echo -e "\n${Y}Grabbing ${element} from ${RE}${site} $@"
      terminus backup:get ${site} --element=${element} --to=${dir} $@ &

      PIDS+=" $!"
      sitemap["$!"]="${site}"

      sleep 3 
    done

  for p in $PIDS; do
    if wait $p; then
      echo "${sitemap["$p"]} succeeded"
    else
      echo "${sitemap["$p"]} failed"
    fi
  done

  if [ $element == 'db'  ]
  then
    echo -e "\n${Y}Unzipping db files in ${dir}${RE} $@"
    gunzip ${dir}/*

    for site in $sites; do
      #mysql -hsupdevmdb01.mariadb.database.azure.com -uazuremdb@supdevmdb01 -pAdamTheGreat1! -e "DROP DATABASE ${site}"
      echo -e "\n${Y}Creating database for ${site}${RE} $@"
      mysql -hsupdevmdb01.mariadb.database.azure.com -uazuremdb@supdevmdb01 -pAdamTheGreat1! -e "CREATE DATABASE IF NOT EXISTS ${site}"
      echo -e "\n${R}Importing ${site} database${RE} $@"
      mysql -hsupdevmdb01.mariadb.database.azure.com -uazuremdb@supdevmdb01 -pAdamTheGreat1! ${site} < ${dir}/jcc-${site}*.sql
    done
  fi
}

case $1 in

  --options|-o)
    show_help
    echo -e "${Y}Options:${RE}"
    terminus backup:get --help | grep "^\s*-"
    ;;
  --help|-h|-?)
    show_help
    ;;
  *)
    env=$1
    element=$2
    dir=$3
    shift 3
    echo $@
    do_command $@
    ;;

esac
