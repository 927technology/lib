shell.process.start() {
  # description

  # argument variables
  local _command=
  local _preserve_environment=
  local _shell="/bin/sh"
  local _std_err=
  local _std_out=
  local _user=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json_processes="{}"
  local _tag=shell.process.kill

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -c | --command )
        shift
        _command="${1}"
      ;;
      -s | --shell )
        shift
        _shell="--shell=${1}"
      ;;
      -p | --preserve-environment )
        _preserve_environment="--preserve-environment"
      ;;
      -se | --std-err )
        shift
        _std_err="2> ${1}"
      ;;
      -so | --std-out )
        shift
        _std_err="1> ${1}"
      ;;
      -u | --user )
        shift
        _user="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_command} ]]  && \
      [[ ! -z ${_user}    ]]; then
  
    # start
    if ${cmd_su} ${_user} ${_shell} ${_preserve_environment} "--command=${_command}"; then
      >&2 echo 10 start
      echo ${cmd_sudo} ${_user} ${_shell} ${_preserve_environment} "--command=${_command}" 
      shell.log --screen --message "starting ${_command} successful" --tag ${_tag} --remote-server ${LOG_SERVER}
      >&2 echo 20 start
    else
      shell.log --screen --message "starting ${_command} failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}