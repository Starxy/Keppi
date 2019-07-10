#!/bin/sh
# utils

# 标准错误输出打印错误信息
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# 标准输出打印消息
msg(){
  echo "$@" >&1
}

# 判断某个命令是存在
require(){
  if [[ "$(command -v $1)" ]]; then
    return 0
  else
    err "require $1 but it's not installed. Aborting."
    exit 1
  fi
}