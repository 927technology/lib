oci.network.drg_route_distribution_statement.list() {
  # local variables
  local _json="{}"
  local _route_distribution_id=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -drdi  | --drg-route-distribution-id )
        shift
        _route_distribution_id="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  _json=$( ${cmd_oci} network drg-route-distribution-statement list --route-distribution-id ${_route_distribution_id} --profile ${_profile} | ${cmd_jq} -c '.data' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  
  # set exit stringcompute shape list
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}