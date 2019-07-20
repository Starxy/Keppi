#!/bin/bash
# 检查外网 ip 地址

# 获取网卡 ip
# get_interface_ip(){
#   extip="$(ip -o -4 addr list | grep "$1" | awk '{print $4}' | cut -d/ -f1)"
#   echo "${extip}"
# }

# 获取外网ip
get_wan_ip(){
  get_ip_url="ns1.dnspod.net:6666"
  extip="$(curl -s -k ${get_ip_url})"
  echo "${extip}"
}

# 判断是否属于内网 ip
check_inter_ip(){
  check="$(echo "$1" | grep -E '(((10)|(100\.64)|(172\.16)|(192\.168))(\.[[:digit:]]{1,3}){1,3})')"
  if [[ -z "${check}" ]]; then
    echo 0 #公网 ip
  else
    echo 1 #内网 ip
  fi
}

# 重新拨号
# renew_pppoe(){
#   if [[ "$(command -v poff)" && "$(command -v pon)"]];then
#     poff && pon dsl-provider
#     sleep 5
#   fi
# }

