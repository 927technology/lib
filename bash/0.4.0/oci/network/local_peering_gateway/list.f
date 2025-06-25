oci.network.local_peering_gateway.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_local_peering_gateway=0
  local _local_peering_gateway_id=
  local _json="{}"
  local -a _json_local_peering_gateway=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _json_local_peering_gateway_attachments
  local _id=
  local _json_compartments=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -c  | --compartments )
        shift
        _json_compartments="${1}"
      ;;
      -i  | --id )
        shift
        _id="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # get compartments
  if [[ -z ${_json_compartments} ]]; then
    _json_compartments=$( oci.iam.compartment.list --id ${_id} --profile ${_profile} )
  fi

  # itterate compartments by id
  for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -r '.[].id'); do
    
    # get local_peering_gateways in each compartment
    for local_peering_gateway in $( ${cmd_oci} network local-peering-gateway list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      _local_peering_gateway_id=$( ${cmd_echo} ${local_peering_gateway} | ${cmd_jq} -r '.id' )
      
      # add local_peering_gateway to json
      _json_local_peering_gateway[${_count_local_peering_gateway}]="${local_peering_gateway}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to local_peering_gateway in json
      _json_local_peering_gateway[${_count_local_peering_gateway}]=$( json.set --json ${_json_local_peering_gateway[${_count_local_peering_gateway}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_local_peering_gateway++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_local_peering_gateway array
  _json=$( ${cmd_echo} "${_json_local_peering_gateway[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}
