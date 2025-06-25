oci.network.drg.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_drg=0
  local _drg_id=
  local _json="{}"
  local -a _json_drg=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _json_drg_attachments
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
      -da  | --drg-attachments )
        shift
        _json_drg_attachments="${1}"
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

  # get drg-attachments
  if [[ -z ${_json_drg_attachments} ]]; then
    _json_drg_attachments=$( oci.network.drg_attachment.list --id ${_id} --profile ${_profile} )
  fi

  # itterate compartments by id
  for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -r '.[].id'); do
    
    # get drgs in each compartment
    for drg in $( ${cmd_oci} network drg list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      _drg_id=$( ${cmd_echo} ${drg} | ${cmd_jq} -r '.id' )
      
      # add drg to json
      _json_drg[${_count_drg}]="${drg}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to drg in json
      _json_drg[${_count_drg}]=$( json.set --json ${_json_drg[${_count_drg}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add drg-attachment to instance in json
      _json_drg[${_count_drg}]=$( json.set --json ${_json_drg[${_count_instance}]} --key .\"drg-attachments\" --value "$( ${cmd_echo} ${_json_drg_attachments} | ${cmd_jq} -c '[ .[] | select(."drg-id" == "'${_drg_id}'") ]' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add drg-route-distribution
      _json_drg[${_count_drg}]=$( json.set --json ${_json_drg[${_count_instance}]} --key .\"drg-route-distribution\" --value "$( oci.network.drg_route_distribution.list --drg-id ${_drg_id} --profile ${_profile} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add drg-route-table to drg in json
      _json_drg[${_count_drg}]=$( json.set --json ${_json_drg[${_count_instance}]} --key .\"drg-route-table\" --value "$( oci.network.drg_route_table.list --drg-id ${_drg_id} --profile ${_profile} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_drg++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_drg array
  _json=$( ${cmd_echo} "${_json_drg[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}
