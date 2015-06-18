#!/bin/bash

server=$1

for build in optimized serial parallel
do
  log_folder_name="tmp/logs/$server/$build"
  rm -fr $log_folder_name
  mkdir -p $log_folder_name

  for times in {1..5}
  do
    log_file_name="$build.$times"
    log_path="$log_folder_name/$log_file_name.log"

    cp codeship-steps.$build.yml codeship-steps.yml
    echo "Activating Docker Machine: $build.$server.$times"
    echo "-----------------"
    date
    docker-machine active $server
    docker-machine ls
    eval "$(docker-machine env $server)"

    echo "--- DOCKER CLEANUP ---"
    docker-machine ssh $server "sudo docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes" &> $log_path.cleanup
    docker-machine ssh $server "df -h"

    echo "--- DOCKER ENVIRONMENT ---"
    env | grep DOCKER

    echo "--- DOCKER BUILD ---"
    time jet steps &> $log_path
    jet_exit_status=$?
    echo "EXIT_STATUS: $jet_exit_status"
    cpu_time=`grep -r COMMAND_RESULTS $log_path | grep -o "\d*\.\d*$" | paste -sd+ - | bc`
    echo "CPU TIME: $cpu_time"
    echo "-----------------"
  done
done
