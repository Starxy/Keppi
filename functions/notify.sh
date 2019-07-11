#!/bin/sh

# 单发短信
smsSingleSender(){
  url="https://yun.tim.qq.com/v5/tlssmssvr/sendsms?sdkappid=xxxxx&random=xxxx"
}

notice_msg(){
  if [[ -z "${tg_bot}" ]]; then
    # 开启 telegram bot 提醒
    if [[ -z "${tg_bot_token}" && -z "${tg_chat_id}" ]]; then
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
  if [[ require "wget" ]]; then
      wget --quiet --no-check-certificate  --output-document=- \
      --post-data "${params}" "${url}"
  fi
}