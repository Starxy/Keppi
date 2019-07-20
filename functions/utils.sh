#!/bin/bash
# utils

# 标准错误输出打印错误信息
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

# 标准输出打印消息
msg(){
  echo "$@" >&1
}