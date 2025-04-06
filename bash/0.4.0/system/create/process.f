system.create.process() {
  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # argument variables
  local _arguments=
  local _pid=
  local _process=
  local _status=
  local _verbose=${false}
  
  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  
  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a  | --arguments )
        shift
        _arguments=${1}
      ;;
      -p  | --process )
        shift
        _process=${1}
      ;;
      -v  | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.process    |=.+ '"${_process}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.arguments  |=.+ '"${_arguments}"'"' )

  if [[ -f ${_process} ]]; then
    ${_process} ${_arguments}
    _status=( $( ${cmd_echo} ${?} ${!} ) )
    _pid=${_status[0]}

    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.present  |=.+ true' )

    if [[ ${_status[0]} != ${exitok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.pid  |=.+ '${_pid} )
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.pid  |=.+ null' )
      
      (( _error_count++ ))
    fi

  else
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.present  |=.+ false' )

    (( _error_count++ ))
  fi

  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # set exit_string
  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -c )


  # exit
  ${cmd_echo} ${_exit_string}

  return ${_exit_code}
}