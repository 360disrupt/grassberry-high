#!/bin/bash
RestartDaemon () {
  echo "restarting pm2"
  pm2 kill && pm2 start /home/pi/app/processes.json
}

Deploy () {
  echo "stopping pm2"
  pm2 stop all
  #delete old version
  if [ -d /home/pi/app/dist ]; then
    mv /home/pi/app/dist /home/pi/app/dist.del
  fi

  if [ -d /home/pi/app/dist.new ]; then #from rsync
    mv /home/pi/app/dist.new /home/pi/app/dist
  else #err
    echo "WARNING no deployment files"
    exit 1
  fi
}

UnzipVersion () {
  path="$1"
  if [[ "$path" == "" ]]; then
    echo "No Unzip Path specified in script"
    return 1
  fi

  #in case a failed installation exists
  if [ -d /home/pi/app/dist.unzip/dist ]; then
    rm -rf /home/pi/app/dist.unzip
  fi

  #create directory and unzip into
  mkdir /home/pi/app/dist.unzip
  tar -xzf "$path" -C /home/pi/app/dist.unzip
  rm -rf "$path"

  #move files from this directory into according folders
  mv /home/pi/app/dist.unzip/dist /home/pi/app/dist.new

  if [ -f /home/pi/app/dist.unzip/bower.json ]; then
    mv /home/pi/app/dist.unzip/bower.json /home/pi/app/bower.json
  fi

  if [ -f /home/pi/app/dist.unzip/package.json ]; then
    mv /home/pi/app/dist.unzip/package.json /home/pi/app/package.json
  fi

  rm -rf /home/pi/app/dist.unzip
}

InstallDependencies () {
  cd /home/pi/app/ || exit 1
  npm install --production --config.interactive=false
  sudo -u pi bower install --config.interactive=false
}

Clean () {
  #clean
  rm -rf /home/pi/app/dist.del
  echo "Cleaned App"
}

Main () {
  echo whoami
  noInstall=$1

  #unzip if there is a zipped version (autodownloader)
  if [ -f /home/pi/app/newVersion.tar.gz ]; then
    UnzipVersion "/home/pi/app/newVersion.tar.gz"
  fi

  #dependencies
  if [[ $noInstall != 'true' ]]; then
    echo "installing dep"
    InstallDependencies
  fi

  #deploy or restart
  if [ -d /home/pi/app/dist.new ]; then
    Deploy
    RestartDaemon
    Clean
  else
    echo "NOTHING to DEPLOY just restarting A"
    RestartDaemon
  fi
}

Main "$1"