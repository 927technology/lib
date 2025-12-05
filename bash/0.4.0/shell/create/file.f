shell.create.file() {
  # description

  # argument variables
  local _group=
  local _mode=
  local _owner=
  local _path=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _file=
  local _parent=
  local _tag=shell.create.path

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
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
      -p | --path )
        shift
        _path="${1}"
      ;;
   
    esac
    shift
  done

  # main
  # create ${_path}
  if [[ ! -z ${_path} ]]; then

    # get parent path
    _file=$( ${cmd_echo} ${_path} | ${cmd_awk} -F"/" '{print $NF}' )
    _parent=$( ${cmd_echo} ${_path} | ${cmd_sed} 's/'${_file}'//g' )

    # does parent exist as a directory or simlink directory
    if [[ -d ${_parent} ]] || ( [[ -L ${_parent} ]] && [[ -d ${_parent} ]] ); then
      
      # path is not a simlink or directory
      if [[ ! -L ${_path} ]] || [[ ! -d ${_path} ]]; then

        # create file      
        if ${cmd_touch} ${_path}; then
          shell.log --screen --message "CREATE: ${_path} SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
        
        else
          shell.log --screen --message "CREATE ${_path} FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
          (( _error_count++ ))
        fi
      else
        shell.log --screen --message "CREATE: ${_path} is a simlink or directory FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
      
      fi
    else
      shell.log --screen --message "CREATE: ${_path} exists SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
    
    fi

    # set owner/group ${_path}
    if [[ -f ${_path} ]] && ( [[ ! -z ${_group} ]] || [[ ! -z ${_owner} ]] ); then
      
      # change owner and group
      if ${cmd_chown} ${_owner}:${_group} ${_path}; then
        shell.log --screen --message "SET: owner/group(${_owner}:${_group}) ${_path} SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
      
      else
        shell.log --screen --message "SET: owner/group(${_owner}:${_group}) ${_path} FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      
      fi
    fi

    # set mode ${_path}
    if [[ -f ${_path} ]] && [[ ! -z ${_mode} ]]; then
      
      # set mode
      if ${cmd_chmod} ${_mode} ${_path}; then
        shell.log --screen --message "SET: mode(${_mode}) ${_path} SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
      
      else
        shell.log --screen --message "SET: mode(${_mode}) ${_path} FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      
      fi
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