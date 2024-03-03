#!/bin/bash

exec 3> /texdocker.log
exec > >(tee -a /dev/fd/3) 2>&1

CONTAINER_NAME="tex_container"
cd $1

docker stop $CONTAINER_NAME

PASSWORD=$(cat ./password)

if ! docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
	docker create --name $CONTAINER_NAME --net=host -e "PASSWORD=$PASSWORD" -v $(readlink -f ../projects):/workdir nicholasbrandt/texdocker
fi

docker restart $CONTAINER_NAME
