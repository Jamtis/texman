#!/bin/bash

NAME="tex_container"
cd $1

docker stop $NAME
docker rm $NAME
PASSWORD=$(cat ./password)
docker run -it --name $NAME --net=host -e "PASSWORD=$PASSWORD" -v $(readlink -f ../projects):/workdir nicholasbrandt/texdocker
