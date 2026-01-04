cgroups.create.namespace () {
  # description

  # argument variables
  local _cpu_quota=100000

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json="{}"
  local _uuid=$( ${cmd_uuidgen} )

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -c | --cpu-quota )
        shift
        _cpu_quota=${1}
      ;;
      -p | --path )
        shift
        _path="${1}"
      ;;
    esac
    shift
  done

  # main
  _json=$( json.set --json ${_json} --key ".uuid" --value ${_uuid} )

  # create cgroup path
  if [[ ! -d /sys/fs/cgroup/cpu/${_uuid} ]]; then
    ${cmd_mkdir} --parents /sys/fs/cgroup/cpu/${_uuid}
    if [[ ${?} == ${exit_ok} ]]; then 
      _json=$( json.set --json ${_json} --key ".exits.path" --value ${true} )
      
    else
      _json=$( json.set --json ${_json} --key ".exits.path" --value ${false} )
      (( _error_count++ ))

    fi
  
    ${cmd_echo} ${_cpu_quota} > /sys/fs/cgroup/cpu/${_uuid}/cpu.cifs_quota_us
    if [[ ${?} == ${exit_ok} ]]; then 
      _json=$( json.set --json ${_json} --key ".exits.cpu_quota" --value ${true} )
      _json=$( json.set --json ${_json} --key ".cpu_quota" --value ${_cpu_quota} )
      
    else
      _json=$( json.set --json ${_json} --key ".exits.cpu_quota" --value ${false} )
      _json=$( json.set --json ${_json} --key ".cpu_quota" --value null )
      (( _error_count++ ))

    fi

    ${cmd_echo} ${$} > /sys/fs/cgroup/cpu/${_uuid}/tasks
    if [[ ${?} == ${exit_ok} ]]; then 
      _json=$( json.set --json ${_json} --key ".exits.task" --value ${true} )
      _json=$( json.set --json ${_json} --key ".task" --value ${$} )
      
    else
      _json=$( json.set --json ${_json} --key ".exits.task" --value ${false} )
      _json=$( json.set --json ${_json} --key ".task" --value null )
      (( _error_count++ ))

    fi


    # mount necessary paths
    [[ ! -d ${_path}/proc ]] && { ${cmd_mkdir} ${_path}/proc || ((_error_count++ )); }
    ${cmd_mount} --types proc none ${_path}/proc
    if [[ ${?} == ${exit_ok} ]]; then 
      _json=$( json.set --json ${_json} --key ".exits.mount.proc" --value ${true} )
      
    else
      _json=$( json.set --json ${_json} --key ".exits.mount.proc" --value ${false} )
      (( _error_count++ ))

    fi

    [[ ! -d ${_path}/sys ]] && { ${cmd_mkdir} ${_path}/sys || ((_error_count++ )); }
    ${cmd_mount} --types sysfs none ${_path}/sys
    if [[ ${?} == ${exit_ok} ]]; then 
      _json=$( json.set --json ${_json} --key ".exits.mount.sys" --value ${true} )
      
    else
      _json=$( json.set --json ${_json} --key ".exits.mount.sys" --value ${false} )
      (( _error_count++ ))

    fi

    [[ ! -d ${_path}dev ]] && { ${cmd_mkdir} ${_path}/dev || ((_error_count++ )); }
    ${cmd_mount} --options bind /dev ${_path}/dev
    if [[ ${?} == ${exit_ok} ]]; then 
      _json=$( json.set --json ${_json} --key ".exits.mount.dev" --value ${true} )
      
    else
      _json=$( json.set --json ${_json} --key ".exits.mount.dev" --value ${false} )
      (( _error_count++ ))

    fi
  fi

  # exit
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} ${_json}
  return ${_exit_code}
}