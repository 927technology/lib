snmp.set.apc9211 () {
  # description

  # argument variables
  local _community=
  local _host=
  local _output=
  local _port=
  local _power=${false}
  local _state=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _oid=
  local _type=

  # parse arguments
  while [[ "${1}" != "" ]]; do 
    case "${1}" in 
      -c | --community )
        shift
        _community="${1}"
      ;;
      -h | --host )
        shift
        _host="${1}"
      ;;
      -p | --port )
        shift
        case "${1}" in
          1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 ) _port="${1}" ;;
        esac
      ;;
      -P | --power )
        _power=${true}
      ;;
      -s | --state )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in
          on  ) _state=1 ;;
          off ) _state=2 ;;
        esac

      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_community} ]]      && \
      [[ ! -z ${_host} ]]           && \
      [[ ! -z ${_port} ]]           && \
      [[ ! -z ${_state} ]]; then
    if [[ ${_power} == ${true} ]]; then
      _oid=.1.3.6.1.4.1.318.1.1.4.4.2.1.3.${_port}
      _type=i

    else
      (( _error_count++ ))
    
    fi
  
    if  [[ ! -z ${_oid} ]]          && \
        [[ ${_power} == ${true} ]]  && \
        [[ ! -z ${_state} ]]; then
      _output=$( ${cmd_snmpset} -v 1 -c ${_community} ${_host} ${_oid} ${_type} ${_state} >/dev/null 2>&1 || (( _error_count++ )) )

    else 
      (( _error_count++ ))

    fi
  else
    (( _error_count++ ))

  fi
  
  # exit
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  [[ ! -z ${_output} ]] && ${cmd_echo} ${_output}
  return ${_exit_code}
}