927.ops.path.create.secrets() {
  # description

  # argument variables
  local _group=
  local _owner=
  local _path=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _tag=927.create.secretspath

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -g | --group )
        shift
        _group="${1}"
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
  # create secrets path
  if [[ ! -f ${_path}/secrets ]]; then
    if ${cmd_mkdir} --parents ${_path}/secrets; then
      shell.log --screen --message "${_path}/secrets created" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "${_path}/secrets creation failed" --tag ${_tag} --remote-server ${LOG_SERVER}
    fi
  fi

  # set owner/group ${_path}/secrets
  if ${cmd_chown} -R ${_owner}:${_group} ${_path}/secrets; then
    shell.log --screen --message "set owner/group for ${_path}/secrets successful" --tag ${_tag} --remote-server ${LOG_SERVER}
  else
    shell.log --screen --message "set owner/group for ${_path}/secrets failed" --tag ${_tag} --remote-server ${LOG_SERVER}
    (( _error_count++ ))
  fi

  # set mode ${_path_gearmand}/secrets
  ${cmd_chmod} 600 -R ${_path_gearmand}/secrets  || (( _error_count++ ))

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}