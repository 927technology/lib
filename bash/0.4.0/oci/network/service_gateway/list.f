oci.network.service_gateway.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_service_gateway=0
  local _service_gateway_id=
  local _json="{}"
  local -a _json_service_gateway=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
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
    
    # get service_gateways in each compartment
    for service_gateway in $( ${cmd_oci} network service-gateway list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      _service_gateway_id=$( ${cmd_echo} ${service_gateway} | ${cmd_jq} -r '.id' )
      
      # add service_gateway to json
      _json_service_gateway[${_count_service_gateway}]="${service_gateway}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to service_gateway in json
      _json_service_gateway[${_count_service_gateway}]=$( json.set --json ${_json_service_gateway[${_count_service_gateway}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_service_gateway++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_service_gateway array
  _json=$( ${cmd_echo} "${_json_service_gateway[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}
