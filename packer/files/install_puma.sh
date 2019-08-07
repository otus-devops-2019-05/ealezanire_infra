#!/bin/bash
DIRECTORY='/home/appuser'

sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

sudo wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
sudo bash -c 'echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

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

sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma




