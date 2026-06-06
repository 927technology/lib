coriolis.get.licensing.appliances() {
  # edited
  # chris murray
  # 20251120

  # description


  # local variables
  local _count_licenses=0
  local _json_license="{}"
  
  # argument variables
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  # set coriolis endpoing
  move.coriolis.set.endpoint --profile ${_profile}

  # itterate appliances
  for appliance in $( ${cmd_coriolis} licensing appliance list -f json 2>/dev/null | ${cmd_jq} -r '.[].ID'  ); do
    # get appliance licenses
    _json_license=$( ${cmd_coriolis} licensing appliance status ${appliance} -f json 2>/dev/null | ${cmd_jq} -c '.current_remaining_migrations = .current_available_migrations - .current_performed_migrations' )

    # add current licenses to total
    _count_licenses=$(( ${_count_licenses} + $( ${cmd_echo} ${_json_license} | ${cmd_jq} -r '.current_remaining_migrations') ))
    
    # output    
    shell.log "${FUNCNAME}(${_profile}) - [NOTICE] ID: ${appliance}, Available Licenses: $( ${cmd_echo} ${_json_license} | ${cmd_jq} -r '.current_remaining_migrations')"

  done

  # output total licenses
  shell.log "${FUNCNAME}(${_profile}) - [NOTICE] Total Available Licenses: ${_count_licenses}"
  
  # error on zero licenses
  [[ ${_count_licenses} > 0 ]] || (( _error_count++ ))

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}