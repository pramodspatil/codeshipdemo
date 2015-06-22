#!/bin/bash

server=$1

for build in optimized serial parallel simple
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
    docker-machine ls
    eval "$(docker-machine env $server)"

    echo "--- DOCKER ENVIRONMENT ---"
    env | grep DOCKER

    echo "--- DOCKER BUILD ---"
    /usr/bin/time -f "TOTAL_RUNTIME = %e" bash -c "jet steps &> $log_path"
    jet_exit_status=$?
    echo "EXIT_STATUS: $jet_exit_status"
    cpu_time=`grep -r COMMAND_RESULTS $log_path | grep -Eo "[0-9]+.[0-9]+" | paste -sd+ - | bc`
    echo "CPU_TIME: $cpu_time"

    echo "--- DOCKER CLEANUP ---"

    # Find all containers that have exited
    containers=`docker ps -a -q | xargs`
    if [[ $containers ]]; then
      # Remove exited containers
      docker stop $containers
      docker rm $containers
    else
      echo "No containers to remove"
    fi

    # Find all images that are not tagged
    images=`docker images -a -q -f dangling=true | xargs`
    if [[ $images ]]; then
      # Remove untagged images
      docker rmi $images
    else
      echo "No images to remove"
    fi

    docker-machine ssh $server "sudo docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes" &> $log_path.cleanup
    docker-machine ssh $server "df -h"

    # List containers and images that remain
    echo "LEFT OVER CONTAINERS"
    docker ps -a
    docker images -a
    echo "RUNNING_PROCESSES: `docker-machine ssh $server "ps -A | wc -l"`"
    echo "-----------------"
  done
done
