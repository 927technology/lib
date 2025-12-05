shell.create.directory() {
  # description

  # argument variables
  local _directory=
  local _group=
  local _mode=
  local _owner=
  local _recursive=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _tag=shell.create.path

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -d | --directory )
        shift
        _directory="${1}"
      ;;
      -g | --group )
        shift
        _group="${1}"
      ;;
      -m | --mode )
        shift
        _mode="${1}"
      ;;
      -o | --owner )
        shift
        _owner="${1}"
      ;;
      -r | --recursive )
        _recursive="-R"
      ;;    
    esac
    shift
  done

  # main
  # create ${_directory}
  if [[ ! -z ${_directory} ]]; then

    # does not exist as a directory, file, or simlink
    if [[ ! -d ${_directory} ]] && [[ ! -f ${_directory} ]] && [[ ! -L ${_directory} ]]; then

      # make ${_directory}      
      if ${cmd_mkdir} --parents ${_directory}; then
        shell.log --screen --message "CREATE: ${_directory} SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
      
      else
        shell.log --screen --message "CREATE: ${_directory} FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      fi

    # directory exists
    elif [[ -d ${_directory} ]]; then
      shell.log --screen --message "CREATE: ${_directory} EXISTS" --tag ${_tag} --remote-server ${LOG_SERVER}
    
    fi

    # set owner/group ${_directory}
    if [[ -d ${_directory} ]] && ( [[ ! -z ${_group} ]] || [[ ! -z ${_owner} ]] ); then
      if ${cmd_chown} ${_recursive} ${_owner}:${_group} ${_directory}; then
        shell.log --screen --message "SET: owner/group(${_owner}:${_group}) ${_directory} SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
      
      else
        shell.log --screen --message "SET: owner/group(${_owner}:${_group}) ${_directory} FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      
      fi
    fi

    # set mode ${_directory}
    if [[ -d ${_directory} ]] && [[ ! -z ${_mode} ]]; then

      if ${cmd_chmod} ${_mode} ${_recursive} ${_directory}; then
        shell.log --screen --message "SET: mode(${_mode}) ${_directory} SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}

      else
        shell.log --screen --message "SET: mode(${_mode}) ${_directory} FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))

      fi
    else
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