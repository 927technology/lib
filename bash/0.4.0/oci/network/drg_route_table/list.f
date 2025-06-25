oci.network.drg_route_table.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_route_table=0
  local _route_table_id=
  local _json="{}"
  local -a _json_route_table=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _drg_id=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -di  | --drg-id )
        shift
        _drg_id="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # itterate route_tables
  for route_table in $( ${cmd_oci} network drg-route-table list --drg-id ${_drg_id} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
    # get route_table id
    _route_table_id=$( ${cmd_echo} ${route_table} | ${cmd_jq} -r '.id' )

    _json_route_table[${_count_route_table}]="${route_table}"
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
    
    # add drg-route-rule to drg in json
    _json_route_table[${_count_route_table}]=$( json.set --json ${_json_route_table[${_count_route_table}]} --key .\"drg-route-rules\" --value "$( oci.network.drg_route_rule.list --drg-route-table-id ${_route_table_id} --profile ${_profile} )" )
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    (( _count_route_table++ ))
  done
  
  # build json list form _json_console_history array
  _json=$( ${cmd_echo} "${_json_route_table[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}