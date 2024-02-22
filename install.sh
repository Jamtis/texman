#!/bin/bash

# restore original state after script
original_cwd=$(pwd)
cleanup() {
    # Change back to the original directory upon exit
    cd "$original_cwd"
    exit
}
trap cleanup EXIT

# make sure docker is installed
if command -v docker &> /dev/null ; then
    echo "Docker is installed. Continuing..."
else
    echo "Docker is not installed."
    exit 126
fi

# setup temp folder
TEXDOCKER_FOLDER=$(readlink -f ~/texdocker)
rm -rf $TEXDOCKER_FOLDER
mkdir -p $TEXDOCKER_FOLDER
CONFIG_FOLDER=$(readlink -f $TEXDOCKER_FOLDER/.config)
cp -r ./ $CONFIG_FOLDER
cd $CONFIG_FOLDER

# write password
head /dev/urandom | tr -dc 'a-z0-9' | head -c 16 > password

# prepare service file 
SERVICE_FILE=$(readlink -f ./texdocker)
RUN_FILE=$(readlink -f ./run-docker.sh)
# add path to run-docker.sh to the service file
echo "command=$RUN_FILE" >> $SERVICE_FILE
echo "command_args='$CONFIG_FOLDER'" >> $SERVICE_FILE

# su
# prepare service symlink
SERVICE_SYMLINK='/etc/init.d/texdocker'
su -c "rm $SERVICE_SYMLINK ; ln -s $SERVICE_FILE $SERVICE_SYMLINK"
echo "installation succeeded"
