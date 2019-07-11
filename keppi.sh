#!/bin/sh
# 检测本地网卡 ip 是否为内网
# 如果为内网 ip 则重新拨号
# 公网 ip 则更新 ddns 记录

# Debugging
if [[ -d ".dev-debug" ]]; then
  exec 5>".dev-debug/dev-debug-[$(date +'%Y-%m-%dT%H:%M:%S%z'z)].log"
  BASH_XTRACEFD="5"
  set -x
fi


root_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
functions_dir="${root_dir}/functions"
config_file_path="${root_dir}/setting.conf"

source "${functions_dir}/utils.sh"

# 初始化配置变量
if [[ -f "${config_file_path}" ]]; then
  source "${config_file_path}"
else
  err "cant find setting config"
  exit 1
fi

# 初始化 dnspod 配置
source "${functions_dir}/dnspod.sh"

if [[ -z "${dnspod_token}" ]]; then
  err "please fill in dnspod token."
  exit 1
fi

# # 初始化拨号网卡配置
# source "${functions_dir}/interface.sh"

# if [[ -z "${interface}" ]]; then
#   err "please fill in interface name"
#   exit 1
# fi


if [[ "$(check_interface_ip "${interface}")" ]]; then
  for sub in ${sub_domain_name[*]}; do
    dnsCheck ${domain_name} ${sub}
  done
else
  err "cant get public address"
  exit 1
fi