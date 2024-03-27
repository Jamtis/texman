#!/bin/bash

# restore original state after script
original_cwd=$(pwd)
cleanup() {
    # Change back to the original directory upon exit
    cd "$original_cwd"
    exit
}
trap cleanup EXIT

# install docker rootless
install_docker() {
    # https://virtualzone.de/posts/alpine-docker-rootless/
    sudo apk update
    sudo apk add podman shadow-uidmap fuse-overlayfs iproute2
    sudo rc-update add cgroups
    sudo rc-service cgroups restart
    # ???
    sudo modprobe tun
	sudo su -c "echo tun >> /etc/modules"
	# add user ids
	sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
}

install_texdocker() {
	# setup texdocker folder
	TEXDOCKER_FOLDER=$(readlink -f ~/texdocker)

	# setup .config folder
	CONFIG_FOLDER=$(readlink -f $TEXDOCKER_FOLDER/.config)
	sudo rm -rf $CONFIG_FOLDER
	mkdir -p $CONFIG_FOLDER
	cp -r ./ $CONFIG_FOLDER
	cd $CONFIG_FOLDER

	# setup settings folder
	SETTINGS_FOLDER=$(readlink -f $TEXDOCKER_FOLDER/.settings)
	sudo rm -rf $SETTINGS_FOLDER
	# mkdir -p $SETTINGS_FOLDER
	# cp settings.json $SETTINGS_FOLDER

	# write password
	head /dev/urandom | tr -dc 'a-z0-9' | head -c 16 > ./password

	# prepare service file
	SERVICE_FILE=$(readlink -f ./texdocker)
	RUN_FILE=$(readlink -f ./run-podman.sh)
	# add path to run-docker.sh to the service file / run as user
	echo "command=$RUN_FILE" >> $SERVICE_FILE
	echo "command_user=$USER" >> $SERVICE_FILE
	echo "command_args=$CONFIG_FOLDER" >> $SERVICE_FILE

	# prepare service symlink
	SERVICE_SYMLINK='/etc/init.d/texdocker'
	sudo rm -f $SERVICE_SYMLINK
	sudo ln -s $SERVICE_FILE $SERVICE_SYMLINK
	# only root should write / otherwise user could inject su code
	sudo chmod 744 $SERVICE_FILE
	
    # remove existing container
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
    
    # start texdocker
	sudo rc-service texdocker restart
	echo "installation succeeded"

    # add certificate
    sleep 5
    sudo rm -f /usr/local/share/ca-certificates/localhost.crt
    sudo ln -s $SETTINGS_FOLDER/localhost.crt /usr/local/share/ca-certificates/localhost.crt
    sudo update-ca-certificates
}

# execute
install_docker && install_texdocker
