naemon.restart() {
  # local variables
  # none

  # argument variables
  local _host=
  local _protocol=http
  local _port=3080

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local pid=

  # parse arguments
  while [[ ${1} != "" ]]; do
   case ${1} in 
     -h | --host )
        shift
        _host=${1}
     ;; 
     -p | --port )
        shift
        _port=${1}
     ;;
     -s | --secure )
        _protocol=https
     ;;
    esac
    shift
  done

  # main
  ${cmd_curl} ${_protocol}://${_host}:${_port}/v2/computes 2>/dev/null | ${cmd_jq} -c


  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}