#!/bin/bash

exec &> install-podman.log

# restore original state after script
INSTALL_PATH=${1:-../.texman}

# install docker rootless
if command -v apk 2>&1 >/dev/null; then
    # alpine
    # https://virtualzone.de/posts/alpine-docker-rootless/
    sudo apk update
    sudo apk add podman shadow-uidmap fuse-overlayfs iproute2
fi
if command -v apt 2>&1 >/dev/null; then
    # debian
    sudo apt update
    sudo apt install podman
else
    # linux system unknown
    exit 1
fi

# add user ids
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"

# setup texman folder
while [ -f $INSTALL_PATH ]; do
    # create new folder if file already exists
    random_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    INSTALL_PATH=./.texman_$randomstring
done
TEXMAN_FOLDER=$(readlink -f $INSTALL_PATH)

echo "INSTALLING TEXMAN TO: $TEXMAN_FOLDER"
mkdir -p $TEXMAN_FOLDER
cp *.sh $TEXMAN_FOLDER
cp texman $TEXMAN_FOLDER
echo "MOVE TO: $TEXMAN_FOLDER"
cd $TEXMAN_FOLDER

# setup settings folder
sudo rm -rf .settings
mkdir -p .settings

# write password
read -sp "ENTER NEW PASSWORD:" PASSWORD
if [ -z "$PASSWORD" ]; then
    head /dev/urandom | tr -dc 'a-z0-9' | head -c 16 > ./password
else
    echo $PASSWORD > ./password
fi
sudo chmod 644 ./password
# echo "PASSWORD WAS SET TO $PASSWORD"

echo "UPDATE CONTAINER"
bash update-container.sh

echo "START CONTAINER"
bash start-container.sh

# install texman service
if command -v apk 2>&1 >/dev/null; then
	# prepare service symlink
	SERVICE_FILE=./texman
	SERVICE_SYMLINK='/etc/init.d/texman'
	sudo rm -f $SERVICE_SYMLINK
	sudo ln -s $SERVICE_FILE $SERVICE_SYMLINK
	# only root should write / otherwise user could inject su code
	sudo chmod 744 $SERVICE_FILE

	# add path to ./start-container.sh to the service file / run as user
	echo "command_user=$USER" >> $SERVICE_FILE

    # install rc-service
    sudo rc-update add cgroups
    sudo rc-service cgroups restart
	sudo rc-service texman restart
	sudo rc-update add texman default
fi