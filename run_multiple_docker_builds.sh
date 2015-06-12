#!/bin/bash

server=$1

for times in {1..10}
do
  for build in serial #optimized parallel
  do
    cp codeship-steps.$build.yml codeship-steps.yml
    echo "Activating Docker Machine: $build.$server.$times"
    echo "-----------------"
    date
    docker-machine active $server
    docker-machine ls
    eval "$(docker-machine env $server)"
    env | grep DOCKER
    mkdir -p tmp/logs
    #time jet steps &>
    echo $server > tmp/logs/$build.$server.$times.log
    echo "-----------------"
  done
done
