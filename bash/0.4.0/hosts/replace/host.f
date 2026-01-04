hosts.replace.host() {
  # local variables
  local _address=
  local _host=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -h  | --host )
        shift
        _host="${1}"
      ;;
      -a  | --address )
        shift
        _address="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_host} ]] && \
      [[ ! -z ${_address} ]]; then
    # delete existing entries
    for line in $( ${cmd_grep} -n ${_host} /etc/hosts | ${cmd_awk} -F":" '{print $1}' ); do 
      echo $line
      ${cmd_sed} -i ${line}'d' /etc/hosts || (( _error_count++ ))
    
    done

    # write entry in host file
    ${cmd_echo} -e "${_address}\t\t${_host}" >> /etc/hosts || (( _error_count++ ))
  
  else
    (( _error_count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}