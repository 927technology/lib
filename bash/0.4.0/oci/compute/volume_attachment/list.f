oci.compute.volume_attachment.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_bastion=0
  local _count_volume_attachment=0
  local _json="{}"
  local -a _json_volume_attachment=
  local _id_bastion=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json_bastion=

  # argument variables
  local _id=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
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
  # get namespaces
  _json_bastion=$( oci.compute.instance.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c )

  # itterate bastions by id
  for bastion in $( ${cmd_echo} ${_json_bastion} | ${cmd_jq} -c '.[]' ); do
    # get the availability domain name
    _id_bastion=$( ${cmd_echo} ${bastion} | ${cmd_jq} -r '.id')

    # get volume_attachments in each availability domain
    for volume_attachment in $( ${cmd_oci} compute volume_attachment list --profile ${_profile} --compute-id ${_id_bastion} | ${cmd_jq} -c '.data[]' ); do
      # add volume_attachment to json
      _json_volume_attachment[${_count_volume_attachment}]="${volume_attachment}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add volume_attachment namespace to volume_attachment in json
      _json_volume_attachment[${_count_volume_attachment}]=$( json.set --json ${_json_volume_attachment[${_count_volume_attachment}]} --key .\"volume_attachment-namespace\" --value "$( ${cmd_echo} ${_json_bastion} | ${cmd_jq} -c '.['${_count_bastion}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_volume_attachment++ ))
    done
    (( _count_bastion++ ))
  done
  
  # build json list form _json_volume_attachment array
  _json=$( ${cmd_echo} "${_json_volume_attachment[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}