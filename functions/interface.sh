# 获取网卡 ip
getInterfaceIp(){
  extip=$(ip -o -4 addr list | grep "${interface}" | awk '{print $4}' | cut -d/ -f1)
  echo $extip
}

# 判断是否属于内网 ip
checkInterfaceIp(){
  check=$(getInterfaceIp | grep -E '(((10)|(100\.64)|(172\.16)|(192\.168))(\.[[:digit:]]{1,3}){1,3})')
  if [ "x${check}" = "x" ]; then
    return 1; #公网 ip
  else
    return 0; #内网 ip
  fi
}

# 重新拨号
reNewPPPoE(){
  /usr/bin/poff && /usr/bin/pon dsl-provider
  sleep 5
}