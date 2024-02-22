#!/bin/bash

NAME="tex_container"
echo "move to $1"
cd $1

if docker ps -a --format '{{.Names}}' | grep -q "^$NAME$"; then
    echo "tex_container not running"
    # docker start $NAME
else
    echo "tex_container already running"
fi
docker stop $NAME
docker rm $NAME
PASSWORD=$(cat ./password)
docker run -it --name $NAME --net=host -e "PASSWORD=$PASSWORD" -v $(readlink -f ../projects):/workdir nicholasbrandt/texdocker
