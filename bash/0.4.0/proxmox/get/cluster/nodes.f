proxmox.get.cluster.nodes() {
  # dependancies

  # local variables
  local _args="${@} --path cluster/nodes"
  local _json="{}"
  local _node=

  # argument variables
  local _output=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  
  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -n | --node )
        shift
        _node="${1}"
      ;;
      -o  | --output )
        shift
        _output="${1}"
      ;;
    esac
    shift
  done

  # control variables
  # none

  # main
  if [[ ! -z ${_node} ]]; then
    _json=$( proxmox.get.api ${_args} | ${cmd_jq} '[ .[] | select(.node == "'"${_node}"'") ]' ) || (( _error_count++ ))

  else
    _json=$( proxmox.get.api ${_args} )
    # || (( _error_count++ ))

  fi

  # filter output
  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      node        ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].node' ;;
      cpu         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].cpu' ;;
      count       ) ${cmd_echo} ${_json} | ${cmd_jq}    '. | length' ;;
      type        ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].type' ;;
      maxcpu      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].maxcpu' ;;
      id          ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].id' ;;
      maxdisk     ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].maxdisk' ;;
      level       ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].level' ;;
      uptime      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].uptime' ;;
      status      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].status' ;;
      disk        ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].disk' ;;
      maxmem      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].maxmem' ;;
      cgroup-mode ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[]."cgroup-mode"' ;;
      memory      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].mem' ;

    esac
  else
    ${cmd_echo} ${_json}

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}