oci.compute.vnic_attachment.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_vnic_attachment=0
  local _json="{}"
  local -a _json_vnic_attachment=
  local _id_compartment=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json_compartments=

  # argument variables
  local _id=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -c  | --compartment )
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
    _json_compartments=$( oci.iam.compartment.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c )
  fi

  # itterate compartments by id
  for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.[]' ); do
    # get the availability domain name
    _id_compartment=$( ${cmd_echo} ${compartment} | ${cmd_jq} -r '.id')

    # get vnic_attachments in each availability domain
    for vnic_attachment in $( ${cmd_oci} compute vnic-attachment list --profile ${_profile} --compartment-id ${_id_compartment} | ${cmd_jq} -c '.data[]' ); do
      # add vnic_attachment to json
      _json_vnic_attachment[${_count_vnic_attachment}]="${vnic_attachment}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add vnic_attachment namespace to vnic_attachment in json
      _json_vnic_attachment[${_count_vnic_attachment}]=$( json.set --json ${_json_vnic_attachment[${_count_vnic_attachment}]} --key .\"vnic-attachment\" --value "$( ${cmd_echo} ${_json_compartment} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_vnic_attachment++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_vnic_attachment array
  _json=$( ${cmd_echo} "${_json_vnic_attachment[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}