oci.network.drg_route_distribution.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_drg_route_distribution=0
  local _drg_route_distribution_id=
  local _json="{}"
  local -a _json_drg_route_distribution=

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
  # itterate drg_route_distributions
  for drg_route_distribution in $( ${cmd_oci} network drg-route-distribution list --drg-id ${_drg_id} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
    # get drg_route_distribution id
    _drg_route_distribution_id=$( ${cmd_echo} ${drg_route_distribution} | ${cmd_jq} -r '.id' )

    _json_drg_route_distribution[${_count_drg_route_distribution}]="${drg_route_distribution}"
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
    
    _json_drg_route_distribution[${_count_drg_route_distribution}]=$( json.set --json ${_json_drg_route_distribution[${_count_drg_route_distribution}]} --key .\"drg-route-distribution-statements\" --value "$( oci.network.drg_route_distribution_statement.list --profile ${_profile} --drg-route-distribution-id ${_drg_route_distribution_id} )" )
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    (( _count_drg_route_distribution++ ))
  done
  
  # build json list form _json_console_history array
  _json=$( ${cmd_echo} "${_json_drg_route_distribution[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}