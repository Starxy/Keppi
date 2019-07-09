#!/bin/sh
# dnspod api
# Original by anrip<mail@anrip.com>, https://github.com/anrip/ArDNSPod

# Get Domain IP
# arg: domain
dns_info() {
  local domain_id record_id record_ip
  # Get domain ID
  domain_id="$(api_post "Domain.Info" "domain=$1")"
  domain_id="$(echo "${domain_id}" | sed 's/.*{"id":"\([0-9]*\)".*/\1/')"
  
  # Get Record ID
  record_id="$(api_post "Record.List" "domain_id=${domain_id}&sub_domain=$2")"
  record_id="$(echo "${record_id}" | sed 's/.*\[{"id":"\([0-9]*\)".*/\1/')"
  
  # Last IP
  record_ip="$(api_post "Record.Info" "domain_id=${domain_id}& \
    record_id=${record_id}")"
  record_ip="$(echo "${record_ip}" | sed 's/.*,"value":"\([0-9\.]*\)".*/\1/')"
  #check is a ip adreess
  record_ip="$(echo "${record_ip}" | grep -E "(25[0-5]|2[0-4][[:digit:]]| \
    [0-1][[:digit:]]{2}|[1-9]?[[:digit:]])\.(25[0-5]|2[0-4][[:digit:]]|[0-1] \
    [[:digit:]]{2}|[1-9]?[[:digit:]])\.(25[0-5]|2[0-4][[:digit:]]|[0-1] \
    [[:digit:]]{2}|[1-9]?[[:digit:]])\.(25[0-5]|2[0-4][[:digit:]]|[0-1] \
    [[:digit:]]{2}|[1-9]?[[:digit:]])")"

  # Output IP
  if [[ -z "${record_ip}" ]]; then
    echo "${record_ip}"
    return 0
  else
    err "Get Record Info Failed!"
    return 1
  fi
}

# Get data
# arg: type data
api_post() {
    local agent="DJXDDNS/1.0(galaxy_djx@hotmail.com)"
    local inter="https://dnsapi.cn/${1:?'Info.Version'}"
    local param="login_token=${dnspod_token}&format=json&$2"

    wget --quiet --no-check-certificate  --output-document=- \
      --user-agent="${agent}" --post-data "${param}" "${inter}"
}

# Update
# arg: main domain  sub domain
dns_update() {
    local domain_id record_id record_rs record_cd
    # Get domain ID
    domain_id="$(api_post "Domain.Info" "domain=$1")"
    domain_id="$(echo "${domain_id}" | sed 's/.*{"id":"\([0-9]*\)".*/\1/')"
    
    # Get Record ID
    record_id="$(api_post "Record.List" "domain_id=${domain_id}&sub_domain=$2")"
    record_id="$(echo "${record_id}" | sed 's/.*\[{"id":"\([0-9]*\)".*/\1/')"
    
    # Update IP
    my_ip="$(getInterfaceIp)"
    record_rs="$(api_post "Record.Ddns" "domain_id=${domain_id}& \
      record_id=${record_id}&sub_domain=$2&record_type=A&value=${my_ip}& \
      record_line=默认")"
    record_cd="$(echo "${record_rs}" | sed 's/.*{"code":"\([0-9]*\)".*/\1/')"
    record_ip="$(echo "${record_rs}" \
      | sed 's/.*,"value":"\([0-9\.]*\)".*/\1/')"

    # Output IP
    if [[ "${record_ip}" == "${my_ip}" ]]; then
        if [[ "${record_cd}" == "1" ]]; then
            echo "${record_ip}"
            return 0
        fi
        # Echo error message
        err "$(echo "${record_rs}" | sed 's/.*,"message":"\([^"]*\)".*/\1/')"
        return 1
    else
        err "Update Failed! Please check your network."
        return 1
    fi
}

# DDNS Check
# Arg: Main Sub
dns_check() {
    host_ip="$(getInterfaceIp)"
    msg "Updating Domain: $2.$1"
    msg "hostIP: ${hostIP}"
    last_ip="$(dns_info $1 $2)"
    if [[ $? -eq 0 ]]; then
        msg "lastIP: ${lastIP}"
        if [[ "${host_ip}" != "${last_ip}" ]]; then
            post_rs="$(dns_update "$1" "$2")"
            if [[ $? -eq 0 ]]; then
                msg "postRS: ${post_rs}"
                return 0
            else
                msg "${post_rs}"
                return 1
            fi
        fi
        msg "Last IP is the same as current IP!"
        return 1
    fi
    msg "${last_ip}"
    return 1
}