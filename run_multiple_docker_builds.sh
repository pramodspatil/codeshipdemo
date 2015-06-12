#!/bin/bash

for times in {1..10}
do
  for build in serial #optimized parallel
  do
    cp codeship-steps.$build.yml codeship-steps.yml
    for server in t2.medium c4.large c4xlarge
    do
      echo "Activating Docker Machine: $build.$server.$times"
      echo "-----------------"
      docker-machine active $server
      docker-machine ls
      eval "$(docker-machine env $server)"
      env | grep DOCKER
      mkdir -p tmp/logs
      time jet steps &> tmp/logs/$build.$server.$times.log
      echo "-----------------"
    done
  done
done
