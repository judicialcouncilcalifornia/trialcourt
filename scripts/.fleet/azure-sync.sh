#!/usr/bin/env bash

show_help() {
  name="azure-sync"
  description="Grab db and files from Pantheon and import them to Azure."
  usage="scripts/fleet azure-sync [env] [element] [directory] [farm] [azureenv] [pass]"
  # Use this exact template in all show_help functions for consistentency.
  . ${BASEDIR}/scripts/.fleet/templates/show_help.sh
}

do_command() {
  PIDS=""
  declare -a sitemap

  echo -e "${G}Syncing ${element} to ${azureenv}.${farm}${RE} $@"

  location=${dir}/${farm}
  rm -rf ${location}
  mkdir -p ${location}

  df1=("stanislaus" "butte" "humboldt" "merced" "siskiyou" "nccourt" "tehama" "sierra" "sanbenito" "glenn" "store-front" "supremecourt" "fresno" "newsroom")
  df2=("slo2" "sc" "napa" "madera" "mendocino" "inyo" "mariposa" "alpine" "tuolumne" "deprep" "alameda" "kern" "tularesuperiorcourt")
  df3=( "eldorado" "imperial" "kings" "sutter" "mono" "colusa" "modoc" "yuba" "trinity" "srl" "elcondado")

  if [ $farm == 'df1'  ]; then
    sites_processing=("${df1[@]}")
  elif [ $farm == 'df2'  ]; then
    sites_processing=("${df2[@]}")
  elif [ $farm == 'df3'  ]; then
    sites_processing=("${df3[@]}")
  fi

  for site in "${sites_processing[@]}"; do
    site="jcc-${site}.${env}"
    echo -e "${Y}Grabbing ${element} from ${RE}${site} $@"
    terminus backup:get ${site} --element=${element} --to=${location} $@ &

    PIDS+=" $!"
    sitemap["$!"]="${site}"

    sleep 3
  done
  for p in $PIDS; do
    if wait $p; then
      echo -e "${G}${sitemap["$p"]} download succeeded"
    else
      echo -e "${R}${sitemap["$p"]} download failed"
    fi
  done

  PIDS=""
  if [ $element == 'db'  ]; then
    echo -e "\n${RE}Unzipping db files in ${location}${RE} $@"
    gunzip ${location}/*
    ls -lah  ${location}

    for site in "${sites_processing[@]}"; do
      echo -e "\n${Y}Creating database for ${site}${RE} $@"
      mysql -h${azureenv}-ctcms-${farm}-mdb.mariadb.database.azure.com -uAzureMDB@${azureenv}-ctcms-${farm}-mdb -p${pass} -e "CREATE DATABASE IF NOT EXISTS ${site}"
      echo -e "${R}Importing ${site} database${RE} $@"
      mysql -h${azureenv}-ctcms-${farm}-mdb.mariadb.database.azure.com -uAzureMDB@${azureenv}-ctcms-${farm}-mdb -p${pass} ${site} < ${location}/jcc-${site}*.sql &

      PIDS+=" $!"
      sitemap["$!"]="${site}"

      sleep 20
    done
    for p in $PIDS; do
      if wait $p; then
      echo -e "${G}${sitemap["$p"]} import succeeded"
      else
      echo -e "${R}${sitemap["$p"]} import failed"
      fi
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
    farm=$4
    azureenv=$5
    pass=$6
    shift 6
    echo $@
    do_command $@
    ;;

esac
