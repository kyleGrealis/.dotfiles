#!/bin/bash
# this script will iterate through the git repos and update them


find ~/repos -maxdepth 1 -mindepth 1 -type d | while read dir; do
  echo "$dir"
  cd $dir && git pull
done
