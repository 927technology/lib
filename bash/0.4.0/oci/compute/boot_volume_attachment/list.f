oci.compute.boot_volume_attachment.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_availability_domain=0
  local _count_compartment=0
  local _count_boot_volume_attachment=0
  local _json="{}"
  local -a _json_boot_volume_attachment=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _id=
  local _json_availability_domains=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a  | --availability_domains )
        shift
        _json_availability_domains="${1}"
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

# triple loop ad -> compartment -> boot_volume_attachment


  # main
  # get availability_domains
  if [[ -z ${_json_availability_domains} ]]; then
    _json_availability_domains=$( oci.iam.availability_domain.list --id ${_id} --profile ${_profile} )
  fi

  # get vnic-attachments
  _json_vnic_attachment=$( oci.compute.vnic_attachment.list --id ${_id} --profile ${_profile} )

  # itterate availability_domains by id
  for availability_domain in $( ${cmd_echo} ${_json_availability_domains} | ${cmd_jq} -r '.[].name'); do
    
    # get boot_volume_attachments in each availability_domain
    for boot_volume_attachment in $( ${cmd_oci} compute boot-volume-attachment list --availability_domain ${availability_domain} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # add boot_volume_attachment to json
      _json_boot_volume_attachment[${_count_boot_volume_attachment}]="${boot_volume_attachment}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add availability_domain to boot_volume_attachment in json
      _json_boot_volume_attachment[${_count_boot_volume_attachment}]=$( json.set --json ${_json_boot_volume_attachment[${_count_boot_volume_attachment}]} --key .\"availability-domain\" --value "$( ${cmd_echo} ${_json_availability_domains} | ${cmd_jq} -c '.['${_count_availability_domain}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_boot_volume_attachment++ ))
    done
    (( _count_availability_domain++ ))
  done
  
  # build json list form _json_boot_volume_attachment array
  _json=$( ${cmd_echo} "${_json_boot_volume_attachment[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}