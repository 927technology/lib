move.list.network.map() {
  # local variables
  local _path=~move/move

  # argument variables
  local _filter=
  local _network=
  local _id=
  local _short=${false}

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} ${1} | lcase )
      ;;
      -n | --network )
        shift
        _network="${1}"
      ;;
      -i | --id )
        _id=${true}
      ;;
      -s | --short )
        _short=${true}
      ;;
    esac
    shift
  done

  # main
  if    [[ ! -z ${_network} ]]                && \
        [[ -d ${_path}/networks ]]; then
    ${cmd_cat} ${_path}/networks/*.json | ${cmd_jq} '. | select(.vsphere.network == "'${_network}'")' && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  elif  [[ ! -z ${_filter} ]]; then
    if    [[ ${_short} == ${true} ]]; then
      ${cmd_cat} ${_path}/networks/*.json | ${cmd_jq} '. | select( (.vsphere.network? | ascii_downcase ) | match("'${_filter}'"))' | ${cmd_jq} '.vsphere.network | ascii_downcase' | ${cmd_jq} -s '. | unique | sort' | ${cmd_jq} -r '.[]'
    
    elif  [[ ${_id} == ${true} ]]; then
      ${cmd_cat} ${_path}/networks/*.json | ${cmd_jq} '. | select( (.vsphere.network? | ascii_downcase ) | match("'${_filter}'"))' | ${cmd_jq} -r '.id'
    
    else
      ${cmd_cat} ${_path}/networks/*.json | ${cmd_jq} '. | select( (.vsphere.network? | ascii_downcase ) | match("'${_filter}'"))' | ${cmd_jq} -s

    fi

  elif  [[ ${_short} == ${true} ]]            && \
        [[ -d ${_path}/networks ]]; then
    ${cmd_cat} ${_path}/networks/*.json | ${cmd_jq} -r '.vsphere.network' && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  elif [[ -d ${_path}/networks ]]; then
    ${cmd_cat} ${_path}/networks/*.json | ${cmd_jq} -s  && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  
  else
    _exit_code=${exit_crit}
  
  fi

  # exit
  return ${_exit_code}
}