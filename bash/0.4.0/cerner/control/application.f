cerner.control.application() {
  # local variables
  # none

  # argument variables
  local _application=
  local _host=
  local _task=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a  | --application)
        shift
        _application=$( ${cmd_echo} "${1}" | lcase )
      ;;      
      -t  | --task )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in
          start     ) _task=$( ${cmd_echo} "${1}" | lcase )  ;;
          stop      ) _task=$( ${cmd_echo} "${1}" | lcase )  ;;
          validate  ) _task=$( ${cmd_echo} "${1}" | lcase )  ;;
        esac
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_application} ]] && \
      [[ ! -z ${_host} ]] && \
      [[ ! -z ${_task} ]]; then
    # source control plugin
    . ${_lib_root}/cerner/plugins/${_task}/${_application}.p

    # call plugin
    cerner.${_task}.application --host ${_host} || (( _error_count++ ))

  else
    (( _error_count++ ))

  fi

  # set exit code
  if [[ ${_error_count} != 0 ]]; then
    _exit_code=${exit_crit}
    _exit_string=FAILURE

  else
    _exit_code=${exit_ok}
    _exit_string=COMPLETE

  fi

  # exit
  shell.log "${FUNCNAME}(${_task}) - [${_exit_string}] Host: ${_host}, Application ${_application}"
  return ${_exit_code}
}