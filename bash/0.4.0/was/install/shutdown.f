was.install.shutdown() {
  # local variables
  local _count=0
  local _count_process=
  local _count_error=0
  local _domain=cernerasp.com
  local _domain_pam=pam.cernerasp.com
  local _retry=5
  local _sleep=5
  local _username=root

  # argument variables
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
      -pw  | --password )
        shift
        _password="${1}"
      ;;
      -n | -h | --host | --name )
        shift
        _name="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_name}          ]]  && \
      [[ ! -z ${_username_pam}  ]]  && \
      [[ ! -z ${_password}      ]]; then
    while [[ -z ${_count_process} ]] && \
          [[ ${_count} < ${_retry}  ]]; do
      (( _count++ ))
      shell.log "${FUNCNAME}(${_profile}) - [WAS] Host: ${_name}, Attempt: ${_count}/${_retry}"

      if ${cmd_scp}
      

      _count_process=$(
        ${cmd_sshpass}                          \
          -p ${_password}                       \
            ${cmd_ssh}                          \
              -t                                \
              -p 22                             \
              -o "StrictHostKeyChecking no"     \
              ${_username_pam}@${_domain_pam}   \
              ${_username}@${_name}.${_domain}  \
                " /usr/bin/ps -ef |             \
                  /usr/bin/grep  ^wasadmin |    \
                  /usr/bin/grep -c  \/opt\/websphere\/appserver\/java\/bin\/java" \
                2>/dev/null |                   \
                /usr/bin/tail -n +2
      )
      if [[ -z ${_count_process} ]]; then
        (( _count_error++ ))
        ${cmd_sleep} ${_sleep}
      fi
    done

    # if no successfull communication is achieved, increment err counter
    [[ ${_count_error} == ${_retry} ]] && (( _error_count++ ))

    shell.log "${FUNCNAME}(${_profile}) - [WAS] Host: ${_name}, Count: ${_count_process}"

  else
    shell.log "${FUNCNAME}(${_profile}) - [ERROR] Syntax"

  fi

  # exit
  [[ ${_count_error} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok} 

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"
  
  ${cmd_echo} ${_count_process}

  return ${_exit_code}
}