#!/bin/bash

exec 3> /texdocker.log
exec > >(tee -a /dev/fd/3) 2>&1

CONTAINER_NAME="tex_container"
cd $1

docker stop $CONTAINER_NAME

PASSWORD=$(cat ./password)

if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
	docker rm $CONTAINER_NAME
fi

EXT_PROJECTS_FOLDER=$(readlink -f ../projects)
mkdir -p $EXT_PROJECTS_FOLDER
INT_PROJECTS_FOLDER=/workdir
EXT_SETTINGS_FOLDER=$(readlink -f ../.settings)
mkdir -p $EXT_PROJECTS_FOLDER
INT_SETTINGS_FOLDER=/root/.local/share/code-server/User

docker create --name $CONTAINER_NAME --net=host -e "PASSWORD=$PASSWORD" -v $EXT_PROJECTS_FOLDER:$INT_PROJECTS_FOLDER -v $EXT_SETTINGS_FOLDER:$INT_SETTINGS_FOLDER nicholasbrandt/texdocker

docker restart $CONTAINER_NAME
