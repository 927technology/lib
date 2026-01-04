cgroups.delete.namespace () {
  # description

  # argument variables
  local _path=
  local _uuid=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json="{}"
  local _uuid=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -i | --id )
        shift
        _uuid="${1}"
      ;;
      -p | --path )
        shift
        _path="${1}"
    esac
    shift
  done

  # main
  # umount necessary paths
  if  [[ ! -z ${_path} ]] &&
      [[ ! -z ${_uuid} ]]; then
    [[ -d ${_path}/proc ]] && { ${cmd_umount} ${_path}/proc || ((_error_count++ )); }

    [[ -d ${_path}/sys ]] && { ${cmd_umount} ${_path}/sys || ((_error_count++ )); }

    [[ -d ${_path}dev ]] && { ${cmd_umount} ${_path}/dev || ((_error_count++ )); }
    
    # delete cgroup path
    [[ -d /sys/fs/cgroup/cpu/${_uuid} ]] && { ${cmd_rm} --force --recursive /sys/fs/cgroup/cpu/${_uuid} || (( _error_count++ )); }
  
  fi

  # exit
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} ${_output}
  return ${_exit_code}
}




# delete /sys/fs/cgroup folder
# find foo -depth -type d -print -exec rmdir {} \;