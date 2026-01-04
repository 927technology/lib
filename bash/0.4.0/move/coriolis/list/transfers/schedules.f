move.coriolis.list.transfers.schedules() {
  # local variables
  local _path=~move/coriolis

  # argument variables
  local _short=${false}

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
    while [[ ${1} != "" ]]; do 
    case ${1} in
      -s | --short )
        _short=${true}
      ;;
    esac
    shift
  done

  # main
  if  [[ ${_short} == ${true} ]]            && \
      [[ -d ${_path}/transfers/${MOVE_PROFILE}/schedules ]]; then
    ${cmd_cat} ${_path}/transfers/${MOVE_PROFILE}/schedules/*.json 2>/dev/null | ${cmd_jq} '[ .ID ]' | ${cmd_jq} '. | sort | .[]' | ${cmd_jq} -r && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  elif  [[ -d ${_path}/transfers/${MOVE_PROFILE}/schedules ]]; then
    ${cmd_cat} ${_path}/transfers/${MOVE_PROFILE}/schedules/*.json 2>/dev/null | ${cmd_jq} -sc && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  else
    _exit_code=${exit_crit}

  fi

  # exit
  return ${_exit_code}
}