#!/bin/bash
DIRECTORY='/home/appuser'

sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

echo $DIRECTORY
if [ -d "$DIRECTORY" ]; then
        cd $DIRECTORY
else
        mkdir "$DIRECTORY"
        cd $DIRECTORY
fi

set -e

APP_DIR=${1:-$HOME}

git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install

#sudo mv /tmp/puma.service /etc/systemd/system/puma.service
#sudo systemctl start puma
#sudo systemctl enable puma
