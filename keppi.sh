#!/bin/sh
# 检测本地网卡 ip 是否为内网
# 如果为内网 ip 则重新拨号
# 公网 ip 则更新 ddns 记录

# Debugging
if [[ -d ".dev-debug" ]]; then
  exec 5>".dev-debug/dev-debug-[$(date +'%Y-%m-%dT%H:%M:%S%z')].log"
  BASH_XTRACEFD="5"
  set -x
fi


root_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
functions_dir="${root_dir}/functions"
config_file_path="${root_dir}/setting.conf"


start_check(){
  count=1
  while [ $count -le 30 ]; 
  do
    if checkInterfaceIp ; then
        reNewPPPoE
      else
        echo "get public ip address"
        startUpdateDns
        break
    fi
    if [ $count -eq 30 ]; then
      echo "cant get public ip address"
      exit 1
    fi
    let "count++"
  done 
}

startUpdateDns(){
  for sub in ${subDomainName[*]}
  do
    dnsCheck ${domainName} ${sub}
  done
}

if [[ -f "${config_file_path}" ]]; then
  source "${config_file_path}"
else
  err "cant find setting config"
  exit 1
fi

if [[ -z "${dnspod_token}" ]]; then
  err "please fill in dnspod token."
  exit 1
fi

if [[ -z "${interface}" ]]; then
  err "please fill in interface name"
  exit 1
fi