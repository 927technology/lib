oci.compute.console_history.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_console_history=0
  local _json="{}"
  local -a _json_console_history=

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
    _json_compartments=$( oci.iam.compartment.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c )
  fi

  # get vnic-attachments
  _json_vnic_attachment=$( oci.compute.vnic_attachment.list --id ${_id} --profile ${_profile} )

  # itterate compartments by id
  for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -r '.[].id'); do
    
    # get console_historys in each compartment
    for console_history in $( ${cmd_oci} compute console-history list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do

      # get compute id
      _console_history_id=$( ${cmd_echo} ${console_history} | ${cmd_jq} -r '.id' )

      # add console_history to json
      _json_console_history[${_count_console_history}]="${console_history}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to console_history in json
      _json_console_history[${_count_console_history}]=$( json.set --json ${_json_console_history[${_count_console_history}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      (( _count_console_history++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_console_history array
  _json=$( ${cmd_echo} "${_json_console_history[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}