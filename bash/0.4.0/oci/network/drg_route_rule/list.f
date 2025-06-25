oci.network.drg_route_rule.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_drg_route_rule=0
  local _drg_route_rule_id=
  local _json="{}"
  local -a _json_drg_route_rule=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _drg_route_table_id=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -drti  | --drg-route-table-id )
        shift
        _drg_route_table_id="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # itterate drg_route_rules
  for drg_route_rule in $( ${cmd_oci} network drg-route-rule list --drg-route-table-id ${_drg_route_table_id} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
    # get drg_route_rule id
    _drg_route_rule_id=$( ${cmd_echo} ${drg_route_rule} | ${cmd_jq} -r '.id' )

    _json_drg_route_rule[${_count_drg_route_rule}]="${drg_route_rule}"
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
    
    (( _count_drg_route_rule++ ))
  done
  
  # build json list form _json_console_history array
  _json=$( ${cmd_echo} "${_json_drg_route_rule[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}