oci.iam.fault_domain.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_availability_domain=0
  local _count_fault_domain=0
  local _json="{}"
  local -a _json_fault_domain=
  local _name_availability_domain=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json_availability_domain=

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
  # get availability domains
  _json_availability_domain=$( oci.iam.availability_domain.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c )

  # itterate availability_domains by id
  for availability_domain in $( ${cmd_echo} ${_json_availability_domain} | ${cmd_jq} -c '.[]' ); do
    # get the availability domain name
    _name_availability_domain=$( ${cmd_echo} ${availability_domain} | ${cmd_jq} -r '.name')


    # get fault_domains in each availability domain
    for fault_domain in $( ${cmd_oci} iam fault-domain list --availability-domain ${_name_availability_domain} --compartment-id ${_id} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # add fault_domain to json
      _json_fault_domain[${_count_fault_domain}]="${fault_domain}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add availability domain to fault_domain in json
      _json_fault_domain[${_count_fault_domain}]=$( json.set --json ${_json_fault_domain[${_count_fault_domain}]} --key .\"availability-domain\" --value "$( ${cmd_echo} ${_json_availability_domain} | ${cmd_jq} -c '.['${_count_availability_domain}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_fault_domain++ ))
    done
    (( _count_availability_domain++ ))
  done
  
  # build json list form _json_fault_domain array
  _json=$( ${cmd_echo} "${_json_fault_domain[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}