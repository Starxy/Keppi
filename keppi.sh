#!/bin/sh

# 检测本地网卡 ip 是否为内网
# 如果为内网 ip 则重新拨号
# 公网 ip 则更新 ddns 记录

# Get script dir
# See: http://stackoverflow.com/a/29835459/4449544
rreadlink() ( # Execute the function in a *subshell* to localize variables and the effect of `cd`.

  target=$1 fname= targetDir= CDPATH=

  # Try to make the execution environment as predictable as possible:
  # All commands below are invoked via `command`, so we must make sure that `command`
  # itself is not redefined as an alias or shell function.
  # (Note that command is too inconsistent across shells, so we don't use it.)
  # `command` is a *builtin* in bash, dash, ksh, zsh, and some platforms do not even have
  # an external utility version of it (e.g, Ubuntu).
  # `command` bypasses aliases and shell functions and also finds builtins 
  # in bash, dash, and ksh. In zsh, option POSIX_BUILTINS must be turned on for that
  # to happen.
  { \unalias command; \unset -f command; } >/dev/null 2>&1
  [ -n "$ZSH_VERSION" ] && options[POSIX_BUILTINS]=on # make zsh find *builtins* with `command` too.

  while :; do # Resolve potential symlinks until the ultimate target is found.
      [ -L "$target" ] || [ -e "$target" ] || { command printf '%s\n' "ERROR: '$target' does not exist." >&2; return 1; }
      command cd "$(command dirname -- "$target")" # Change to target dir; necessary for correct resolution of target path.
      fname=$(command basename -- "$target") # Extract filename.
      [ "$fname" = '/' ] && fname='' # !! curiously, `basename /` returns '/'
      if [ -L "$fname" ]; then
        # Extract [next] target path, which may be defined
        # *relative* to the symlink's own directory.
        # Note: We parse `ls -l` output to find the symlink target
        #       which is the only POSIX-compliant, albeit somewhat fragile, way.
        target=$(command ls -l "$fname")
        target=${target#* -> }
        continue # Resolve [next] symlink target.
      fi
      break # Ultimate target reached.
  done
  targetDir=$(command pwd -P) # Get canonical dir. path
  # Output the ultimate target's canonical path.
  # Note that we manually resolve paths ending in /. and /.. to make sure we have a normalized path.
  if [ "$fname" = '.' ]; then
    command printf '%s\n' "${targetDir%/}"
  elif  [ "$fname" = '..' ]; then
    # Caveat: something like /var/.. will resolve to /private (assuming /var@ -> /private/var), i.e. the '..' is applied
    # AFTER canonicalization.
    command printf '%s\n' "$(command dirname -- "${targetDir}")"
  else
    command printf '%s\n' "${targetDir%/}/$fname"
  fi
)

# 获取网卡ip
checkInterfaceIp(){
  local extip
  extip=$(ip -o -4 addr list | grep ${interface} | awk '{print $4}' | cut -d/ -f1 )
  echo ${extip}
  check=$(echo ${extip} | grep -E '(((10)|(100\.64)|(172\.16)|(192\.168))(\.[[:digit:]]{1,3}){1,3})')
  if [ "x${check}" = "x" ]; then
    echo 1; #公网ip
  else
    echo 0; #内网ip
  fi
}

reNewPPPoE(){
  /usr/bin/poff && /usr/bin/pon dsl-provider
  sleep 2
}

# Token-based Authentication
dnspodToken=""
# Account-based Authentication
dnspodMail=""
dnspodPass=""

domainName=""
subDomainName=""

# interface name
interface=""

DIR=$(dirname -- "$(rreadlink "$0")")

. $DIR/setting.conf

if [ "x${dnspodToken}" = "x" ]; then
  if [ "x${dnspodMail}" = "x" -o "x${dnspodPass}" ]; then
    echo "please fill in at least one verification method."
    exit 1
  fi
fi

if [ "x${interface}" = "x" ]; then
  echo "please fill in interface name"
  exit 1
fi

startCheck(){
  count=0
  flag="0"
  while [ $count -le 30 ]; 
  do
    flag=$(checkInterfaceIp)
    if [ ${flag} = "0" ]; then
      reNewPPPoE
    fi
    count=count+1
  done
  
  if [ ${flag} = "0" ]; then

    echo "can't get public ip address"
    exit 1
  fi  
}

startCheck