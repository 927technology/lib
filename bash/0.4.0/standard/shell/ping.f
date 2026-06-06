shell.ping() {
  # edited
  # chris murray
  # 20260316

  # description
  # 

  # local variables

  # argument variables
  local _name=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -i  | --ip | -n  | --name )
        shift
        _name="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ ! -z ${_name} ]]; then
    shell.log "${FUNCNAME} - [INFO] Host:  ${_name}"

    # ping host
    ${cmd_ping} -c 1 ${_name} >/dev/null 2>&1 || (( _error_count++ ))

    if  [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME} - [SUCCESS] Host:  ${_name}"
    
    else
        shell.log "${FUNCNAME} - [FAILURE] Host:  ${_name}"

    fi
    
  else
    shell.log "${FAILURE} - [INFO] Host:  ${_name}"

    (( _error_count++ ))
  fi

  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  return ${_exit_code}
}