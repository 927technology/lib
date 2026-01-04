move.coriolis.list.deployments() {
  # local variables
  local _json=
  local _path=~move/coriolis

  # argument variables
  local _name=
  local _output=
  local _status=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
    while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -o | --output )
        shift
        _output="${1}"
      ;;
      -s | --short )
        _output=id
      ;;
      -S | --status )
        shift
        _status=$( ${cmd_echo} "${1}" | ucase )
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z  ${_name} ]]            && \
      [[ -d ${_path}/${MOVE_PROFILE}/deployments ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/deployments/*.json 2>/dev/null | ${cmd_jq} '. | select(.Notes | startswith( "'"${_name} "'" ))' && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ -d ${_path}/${MOVE_PROFILE}/deployments ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/deployments/*.json 2>/dev/null | ${cmd_jq} -c && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  else
    _exit_code=${exit_crit}

  fi

  # filter for status
  if [[ ! -z ${_status} ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '. | select(."Status" == "'"${_status}"'")' )
  fi


  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      date        ) ${cmd_date} -d $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.Created' ) +'%s' | from_epoch ;;
      epoch       ) ${cmd_date} -d $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.Created' ) +'%s'              ;;
      id          ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.ID'                                             ;;
      transfer_id ) ${cmd_echo} ${_json} | ${cmd_jq} -r '."Transfer ID"'                                  ;;
      instances   ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.Instances'                                      ;;
      name        ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.Notes' | ${cmd_awk} '{print $1}'                ;;
      notes       ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.Notes'                                          ;;
      status      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.Status | ascii_downcase'                        ;;
    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}