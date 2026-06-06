cerner.stop.application() {
  # local variables
  local _application=eaodr
  local _remote_command="/home/wasadmin/menu_config/graceful_was_shutdown.sh"

  # argument variables
  local _host=
  local _identity=
  local _task=eaodr
  local _user=

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
      -i  | --identity )
        shift
        if  [[ ! -z "${1}" ]] && \
            [[ -f "${1}" ]]; then
              _identity="-i ${1}"
        fi
      ;;
      -u  | --user )
        shift
        _host="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ $( ${cmd_ssh} ${_identity} ${_user}@${_host} "${_remote_command} >/dev/null 2>&1; echo \$?" ) == 0 ]]; then
    _exit_code=${exit_ok}
    _exit_string=COMPLETE
    
  else  
    _exit_code=${exit_crit}
    _exit_string=FAILURE

  fi
  
  # exit
  shell.log "${FUNCNAME}(${_task}) - [${_exit_string}] Host: ${_host}, Application: ${_application}"
  return ${_exit_code}
}