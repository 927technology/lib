function query.systemd.resource {
  # accepts 1 argument osuquery, returns json

  #local variables
  local _err_count=0
  local _exit_code=${exit_unkn}
  local _json="{}"
  local _osquery=${false}
  local _resource=
  local _sanity=${false}

  # parse command arguments
  [[ ${1} != "" ]] && _resource="${1}"
  shift

  while [[ ${1} != "" ]]; do
    case ${1} in
      -o | --osquery )
        _osquery=${true}
      ;;
    esac
    shift
  done

  #main
  case ${_resource} in
    mount | mounts )
      _systemctl_query='*.mount'
      _osquery_query='select * from systemd_units where active_state = "active" and id like "%.mount";'
      _sanity=${true}
    ;;
    service | services )
      _systemctl_query='*.service'
      _osquery_query='select * from systemd_units where active_state = "active" and id like "%.service";'
      _sanity=${true}
    ;;
    target | targets )
      _systemctl_query='*.target'
      _osquery_query='select * from systemd_units where active_state = "active" and id like "%.target";'
      _sanity=${true}
    ;;
    timer | timers )
      _systemctl_query='*.timer'
      _osquery_query='select * from systemd_units where active_state = "active" and id like "%.timer";'
      _sanity=${true}
    ;;
    * )
      (( _err_count++ ))
    ;;
  esac

  if [[ ${_osquery} == ${true} ]] && [[ -f ${cmd_osqueryi} ]] && [[ ${_sanity} == ${true} ]]; then
    _json=$( ${cmd_osqueryi} "${_osquery_query}" --json | ${cmd_jq} -c 2>/dev/null)

    [[ ${?} != ${exit_ok} ]]                                          && (( _exit_code++ ))

  elif [[ ${_osquery} == ${false} ]] && [[ -f ${cmd_docker} ]] && [[ ${_sanity} == ${_true} ]]; then
    _json=$( ${cmd_systemctl} ${_systemctl_query} --no-pager --output json | ${cmd_jq} -c 2>/dev/null)
  

    [[ ${?} != ${exit_ok} ]]                                          && (( _exit_code++ ))

  else
    _json="[]"
    (( _err_code++ ))
  fi

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  _exit_string="${_json}"

  #return
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}