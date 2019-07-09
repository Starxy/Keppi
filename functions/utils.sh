#!/bin/sh
# utils

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

msg(){
  echo "$@" >&1
}