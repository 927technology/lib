oci.network.drg_attachment.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_drg_attachment=0
  local _json="{}"
  local -a _json_drg_attachment=

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
    
    # get drg_attachments in each compartment
    for drg_attachment in $( ${cmd_oci} network drg-attachment list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # add drg_attachment to json
      _json_drg_attachment[${_count_drg-attachment}]="${drg_attachment}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to drg_attachment in json
      _json_drg_attachment[${_count_drg_attachment}]=$( json.set --json ${_json_drg_attachment[${_count_drg_attachment}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_drg_attachment++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_drg_attachment array
  _json=$( ${cmd_echo} "${_json_drg_attachment[@]}" | ${cmd_jq} -sc )


  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}
