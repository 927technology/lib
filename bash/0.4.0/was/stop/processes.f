was.stop.processes() {
  # local variables
  local _count=0
  local _cmd_exit=
  local _retry=5
  # local _script=wrapper_graceful_was_shutdown.sh
  local _script=dummy_script.sh
  local _sleep=5
  local _username=root

  # argument variables
  local _domain=cernerasp.com
  local _domain_pam=pam.cernerasp.com
  local _host=
  local _password=
  local _username_pam=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ "${1}" != "" ]]; do
    case "${1}" in
      -u | --username )
        shift
        _username_pam="${1}"
      ;;
      -ud | --user-domain )
        shift
        _domain_pam="${1}"
      ;;
      -pw  | --password )
        shift
        _password="${1}"
      ;;
      -h | -n | --host | --name )
        shift
        _name="${1}"
      ;;
      -hd | --host-domain )
        shift
        _domain="${1}"
      ;;
    esac
    shift
  done

  # main
  # validate variables and host up status
  if  [[ ! -z ${_name}          ]]  && \
      [[ ! -z ${_username_pam}  ]]  && \
      [[ ! -z ${_password}      ]]  && \
      ${cmd_ping} -c 1 ${_name}.${_domain} >/dev/null 2>&1; then
    
    # try to get process count for up to ${_rerty} times
    while [[ -z ${_cmd_exit} ]] && \
          [[ ${_count} < ${_retry}  ]]; do
      (( _count++ ))
      shell.log "${FUNCNAME}(${_profile}) - [WAS] Host: ${_name}, Attempt: ${_count}/${_retry}"

      # get process count via ssh
      _cmd_exit=$(
        ${cmd_sshpass}                          \
          -p ${_password}                       \
            ${cmd_ssh}                          \
              -t                                \
              -p 22                             \
              -o "StrictHostKeyChecking no"     \
              ${_username_pam}@${_domain_pam}   \
              ${_username}@${_name}.${_domain}  \
                < /usr/local/bin/${_script}     \
                2>/dev/null 
      )

      # failed to get count, sleep and retry
      if [[ -z ${_cmd_exit} ]]; then
        ${cmd_sleep} ${_sleep}
      fi
    done

    # # increment err count if no value is gathered
    # [[ -z ${_count_process} ]] && (( _error_count++ ))

    # # if no successfull communication is achieved, increment err counter
    # [[ ${_count_error} == ${_retry} ]] && (( _error_count++ ))

    # shell.log "${FUNCNAME}(${_profile}) - [WAS] Host: ${_name}, Count: ${_count_process}"

  else
    shell.log "${FUNCNAME}(${_profile}) - [ERROR] Syntax or ping"
    (( _error_count++ ))
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok} 

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"
  
  ${cmd_echo} ${_count_process}

  return ${_exit_code}
}