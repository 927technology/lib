naemon.livestatus.get.service_state() {
  # local variables
  local _is_executing=
  local _livestatus_path=/var/cache/naemon/live
  local _output=
  local _status=

  # argument variables
  local _host=
  local _service=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host )
        shift
        _host="${1}"
      ;;
      -s | --service )
        shift
        _service="${1}"
      ;;
    esac
    shift
  done

  # main
  # validate inputs
  if  [[ ! -z ${_host} ]] && \
      [[ ! -z ${_service} ]]; then
    # get livestatus data
    _output=$( ${cmd_echo} -e "GET services\nColumns:is_executing state\nFilter:display_name = ${_service}\nFilter:host_name = ${_host}" | ${cmd_unixcat}  ${_livestatus_path} )
    
    # parse output
    _is_executing=$( ${cmd_echo} ${_output} | ${cmd_awk} -F";" '{print $1}' )
    _status=$( ${cmd_echo} ${_output} | ${cmd_awk} -F";" '{print $2}' )

    if    [[ ${_is_executing} == ${false} ]] && \
          [[ ${_status} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
    
    elif  [[ ${_is_executing} == ${true} ]]; then
      _exit_code=${exit_warn}
    
    else
      _exit_code=${exit_crit}
    
    fi
  else
    _exit_code=${exit_unkn}

  fi

  # exit
  return ${_exit_code}
}