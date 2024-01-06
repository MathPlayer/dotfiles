#!/bin/bash
# Script used by BitBar/SwiftBar to display Colima and Docker information.

colima_info=$(colima ls --json)
name=$(jq <<< "$colima_info" -r ".name")
cpus=$(jq <<< "$colima_info" ".cpus")
memory=$(jq <<< "$colima_info" ".memory" | numfmt --to=iec --suffix=B)
disk=$(jq <<< "$colima_info" ".disk" | numfmt --to=iec --suffix=B)
status=$(jq <<< "$colima_info" -r ".status")

echo "colima & docker"
echo "---"
echo "Colima Instance: $name"
echo "-- Status: $status"
echo "-- CPUs: $cpus"
echo "-- Memory: $memory"
echo "-- Disk: $disk"
echo "Docker containers:"
docker_containers=$(docker ps -a -q)
for container in $docker_containers; do
  info=$(docker inspect -f '{{.State.Status}} {{ or ( index .Config.Labels "com.docker.compose.service" ) "Unnamed" }} {{.Config.Image}}' $container)
  echo "-- $container -- $info"
done

