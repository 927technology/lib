oci.compute.instance.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_instance=0
  local _json="{}"
  local _json_console_history=
  local _json_vnic_attachment=
  local -a _json_instance=

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

  # get console history
  _json_console_history=$( oci.compute.console_history.list --compartments "${_json_compartments}" --id ${_id} --profile ${_profile} )

  # get vnic-attachments
  _json_vnic_attachment=$( oci.compute.vnic_attachment.list --compartments "${_json_compartments}" --id ${_id} --profile ${_profile} )

  # itterate compartments by id
  for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -r '.[].id'); do
    
    # get instances in each compartment
    for instance in $( ${cmd_oci} compute instance list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do

      # get compute id
      _instance_id=$( ${cmd_echo} ${instance} | ${cmd_jq} -r '.id' )

      # add instance to json
      _json_instance[${_count_instance}]="${instance}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to instance in json
      _json_instance[${_count_instance}]=$( json.set --json ${_json_instance[${_count_instance}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add console history to instance in json - needs to be filtered
      _json_instance[${_count_instance}]=$( json.set --json ${_json_instance[${_count_instance}]} --key .\"console-history\" --value "$( ${cmd_echo} ${_json_console_history} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add vnic-attachment to instance in json
      _json_instance[${_count_instance}]=$( json.set --json ${_json_instance[${_count_instance}]} --key .\"vnic-attachment\" --value "$( ${cmd_echo} ${_json_vnic_attachment} | ${cmd_jq} -c '[ .[] | select(."instance-id" == "'${_instance_id}'") ]' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add volume-attachment to instance in json - needs testing
      # _json_instance[${_count_instance}]=$( json.set --json ${_json_instance[${_count_instance}]} --key .\"vnic-attachment\" --value "$( oci.compute.vnic_attachment.list )" )
      # [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      

      (( _count_instance++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_instance array
  _json=$( ${cmd_echo} "${_json_instance[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}