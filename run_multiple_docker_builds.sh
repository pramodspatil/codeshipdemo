#!/bin/bash

for build in optimized parallel serial
do
  cp codeship-steps.$build.yml codeship-steps.yml
  for server in t2.medium c4.large c4xlarge
  do
    echo "Activating Docker Machine: $server.$build"
    echo "-----------------"
    docker-machine active $server
    docker-machine ls
    eval "$(docker-machine env $server)"
    env | grep DOCKER
    time jet steps > $build.$server.log
    echo "-----------------"
  done
done
