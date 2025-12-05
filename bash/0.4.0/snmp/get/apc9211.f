snmp.get.apc9211 () {
  # description

  # argument variables
  local _community=
  local _host=
  local _name=${false}
  local _output=
  local _port=
  local _power=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _oid=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -p | --port )
        shift
        case ${1} in
          1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 ) _port="${1}" ;;
        esac
      ;;
      -c | --community )
        shift
        _community="${1}"
      ;;
      -h | --host )
        shift
        _host="${1}"
      ;;
      -n | --name )
        _name=${true}
      ;;
      -P | --power )
        _power=${true}
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_community} ]] && \
      [[ ! -z ${_host} ]] && \
      [[ ! -z ${_port} ]]; then
    if [[ ${_name} == ${true} ]]; then
      _oid=.1.3.6.1.4.1.318.1.1.4.4.2.1.4.${_port}

    elif [[ ${_power} == ${true} ]]; then
      _oid=.1.3.6.1.4.1.318.1.1.4.4.2.1.3.${_port}
  
    else
      (( _error_count++ ))

    fi

    if [[ ! -z ${_oid} ]]; then
      _output=$( ${cmd_snmpget} -v 1 -c ${_community} -Onvq ${_host} ${_oid} || (( _error_count++ )) | ${cmd_sed} 's/"//g'  )
    
    else
      (( _error_count++ ))

    fi
  fi
  
  # exit
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} ${_output}
  return ${_exit_code}
}