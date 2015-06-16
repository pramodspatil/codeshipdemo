#!/bin/bash

server=$1

for times in {1..5}
do
  for build in parallel serial #optimized
  do
    log_folder_name="tmp/logs/$server/$build"
    log_file_name="$build.$times"
    log_path="$log_folder_name/$log_file_name"

    rm -fr $log_folder_name
    mkdir -p $log_folder_name

    cp codeship-steps.$build.yml codeship-steps.yml
    echo "Activating Docker Machine: $build.$server.$times"
    echo "-----------------"
    date
    docker-machine active $server
    docker-machine ls
    eval "$(docker-machine env $server)"
    echo "Docker Cleanup"
    bash -lc "docker_cleanup" &> $log_path.cleanup.log
    env | grep DOCKER
    time jet steps &> $log_path.log
    echo "-----------------"
  done
done
