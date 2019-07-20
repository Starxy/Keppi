#!/bin/bash

# 单发短信
smsSingleSender(){
  url="https://yun.tim.qq.com/v5/tlssmssvr/sendsms?sdkappid=xxxxx&random=xxxx"
}

notice_msg(){
  if [[ -n "${tg_bot}" ]]; then
    # 开启 telegram bot 提醒
    if [[ -n "${tg_bot_token}" && -n "${tg_chat_id}" ]]; then
      echo "$(tg_bot_msg "$1")"
      return 0
    else
      err "开启了 telegram bot 但是相关字段未填写"
      return 1
  fi
}

tg_bot_msg(){
  local url="https://api.telegram.org/bot${tg_bot_token}/sendMessage"
  local params="chat_id=${tg_chat_id}&text=$1"
  if [[ require "curl" ]]; then
    if [[ n "${tg_proxy}" ]]
      curl --preproxy "${tg_proxy}" -s -k -X POST "${url}" -d "${params}"
    else
      curl -s -k -X POST "${url}" -d "${params}"
  fi
}