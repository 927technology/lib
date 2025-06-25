oci.network.vcn.list_full() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_vcn=0
  local _json="{}"
  local -a _json_vcn=

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
    
    # get vcns in each compartment
    for vcn in $( ${cmd_oci} network vcn list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      _vcn_id=$( ${cmd_echo} ${vcn} | ${cmd_jq} -r '.id' )

      # add vcn to json
      _json_vcn[${_count_vcn}]="${vcn}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to vcn in json
      _json_vcn[${_count_vcn}]=$( json.set --json ${_json_vcn[${_count_vcn}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add drg to vcn in json
      _json_vcn[${_count_vcn}]=$( json.set --json ${_json_vcn[${_count_vcn}]} --key .drgs --value "$( oci.network.drg.list --profile ${_profile} --id ${_id} | ${cmd_jq} -c '[ .[] | select(."drg-attachments"[]."network-details".id == "'${_vcn_id}'") ]' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}


      # add internet-gateway to vcn in json
      _json_vcn[${_count_vcn}]=$( json.set --json ${_json_vcn[${_count_vcn}]} --key .\"internet-gateways\" --value "$( oci.network.internet_gateway.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c '[ .[] | select(."vcn-id" == "'${_vcn_id}'" ) ]' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add route-table to vcn in json
      _json_vcn[${_count_vcn}]=$( json.set --json ${_json_vcn[${_count_vcn}]} --key .\"route-tables\" --value "$( oci.network.route_table.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c '[ .[] | select(."vcn-id" == "'${_vcn_id}'" ) ]' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add service-gateway to vcn in json
      _json_vcn[${_count_vcn}]=$( json.set --json ${_json_vcn[${_count_vcn}]} --key .\"service-gateways\" --value "$( oci.network.service_gateway.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c '[ .[] | select(."vcn-id" == "'${_vcn_id}'" ) ]' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_vcn++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_vcn array
  _json=$( ${cmd_echo} "${_json_vcn[@]}" | ${cmd_jq} -sc )


  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}