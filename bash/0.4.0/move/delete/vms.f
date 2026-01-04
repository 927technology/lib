move.delete.vms() {
  # local variables
  local _path_move=~move/move

  # argument variables
  local _all=${false}
  local _host=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -a | --all )
        shift
        _all=${true}
      ;;
      -h | --host )
        shift
        _host="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_host} ]] && \
      [[ -f ${_path_move}/migration/${_host}.json ]]; then
      ${cmd_rm} -rf ${_path_move}/migration/vms/${_host}.json && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  
  elif [[ ${_all} == ${true} ]]; then
    ${cmd_rm} -rf ${_path_move}/migration/vms/*.json && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  else
    _exit_code=${exit_crit}
  
  fi

  # exit
  return ${_exit_code}
}