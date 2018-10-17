#!/bin/bash

set -e

START_STOP=$1
CONVERSION_TOOL=$2

if [ -z "$START_STOP" ] || [ -z "$CONVERSION_TOOL" ]; then
  echo "Usage: $0 <start|stop> <tool>"
  exit -1
fi

SERVICE_NAME=$CONVERSION_TOOL

source "./config/tools/$CONVERSION_TOOL.sh"

_get_container_status() {
  container_name=$1
  container_status=$(
    docker inspect --format "{{json .State.Health }}" $container_name |
    jq --raw-output '.Status'
  )
  echo $container_status
}

_wait_for_container_healthy() {
  container_name=$1
  echo "waiting for container $container_name to be healthy"
  until [ "$(_get_container_status $container_name)" == "healthy" ]; do
    echo -n '.'
    sleep 1
  done
  echo "container $container_name is healthy"
}

_wait_for_service_healthy() {
  service_name=$1
  container_name=$(docker-compose ps -q $service_name)
  if [ -z "$container_name" ]; then
    echo "container for service not up: $service_name"
    exit -2
  fi
  _wait_for_container_healthy $container_name
}

_start() {
  docker-compose up --no-start
  docker-compose stop $SERVICE_NAME
  docker-compose start $SERVICE_NAME
  _wait_for_service_healthy $SERVICE_NAME
}

_stop() {
  docker-compose stop $SERVICE_NAME
}

if [ "$START_STOP" == "start" ]; then
  _start
elif [ "$START_STOP" == "stop" ]; then
  _stop
else
  echo "Invalid command: $START_STOP (expected <start|stop>)"
  exit -1
fi
