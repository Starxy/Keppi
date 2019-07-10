# 获取网卡 ip
get_interface_ip(){
  extip="$(ip -o -4 addr list | grep "$1" | awk '{print $4}' | cut -d/ -f1)"
  echo "${extip}"
}

# 判断是否属于内网 ip
check_interface_ip(){
  check="$(get_interface_ip "$1" | grep -E '(((10)|(100\.64)|(172\.16)|(192\.168))(\.[[:digit:]]{1,3}){1,3})')"
  if [[ -z "${check}" ]]; then
    return 0 #公网 ip
  else
    return 1 #内网 ip
  fi
}

# 重新拨号
renew_pppoe(){
  if [[ "$(require poff)" ]]&&[["$(rqeuire pon)"]];then
    poff && pon dsl-provider
    sleep 5
  fi
}