#!/bin/bash

CONTAINER_NAME="tex_container"
cd $1

exec &> run-podman.log

echo "texman: run podman"

PASSWORD=$(cat ./password)

EXT_PROJECTS_FOLDER=$(readlink -f ../projects)
mkdir -p $EXT_PROJECTS_FOLDER
INT_PROJECTS_FOLDER=/workdir
EXT_SETTINGS_FOLDER=$(readlink -f ../.settings)
mkdir -p $EXT_SETTINGS_FOLDER
INT_SETTINGS_FOLDER=/root/.local/share/code-server/

if podman ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "tex_container already exists"
else
    podman create --name $CONTAINER_NAME --net=host -e "PASSWORD=$PASSWORD" -v $EXT_PROJECTS_FOLDER:$INT_PROJECTS_FOLDER -v $EXT_SETTINGS_FOLDER:$INT_SETTINGS_FOLDER nicholasbrandt/texman
fi

podman restart $CONTAINER_NAME
