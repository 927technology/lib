oci.compute.capacity_reservation.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_availability_domain=0
  local _count_compartment=0
  local _count_capacity_reservation=0
  local _json="{}"
  local -a _json_capacity_reservation=

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
  # get availability_domains
  if [[ -z ${_json_availability_domains} ]]; then
    _json_availability_domains=$( oci.iam.availability_domain.list --id ${_id} --profile ${_profile} )
  fi
  
  # get compartments
  if [[ -z ${_json_compartments} ]]; then
    _json_compartments=$( oci.iam.compartment.list --id ${_id} --profile ${_profile} )
  fi

  # itterate availability_domains by name
  for availability_domain in $( ${cmd_echo} ${_json_availability_domains} | ${cmd_jq} -r '.[].name'); do
  # echo availability domain: ${availability_domain}
    # itterate compartments by id
    for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -r '.[].id'); do
    # echo compartment: ${compartment}
      # get capacity_reservations in each availability_domain
      for capacity_reservation in $( ${cmd_oci} compute capacity-reservation list --availability-domain ${availability_domain} --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # echo capacity reservation: ${capacity_reservation}
     
        # add capacity_reservation to json
        _json_capacity_reservation[${_count_capacity_reservation}]="${capacity_reservation}"
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
        
        # add availability_domain to capacity_reservation in json
        _json_capacity_reservation[${_count_capacity_reservation}]=$( json.set --json ${_json_capacity_reservation[${_count_capacity_reservation}]} --key .\"availability-domain\" --value "$( ${cmd_echo} ${_json_availability_domains} | ${cmd_jq} -c '.['${_count_availability_domain}']' )" )
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

        # add compartment to capacity_reservation in json
        # _json_capacity_reservation[${_count_capacity_reservation}]=$( json.set --json ${_json_capacity_reservation[${_count_capacity_reservation}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
        # [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

        (( _count_capacity_reservation++ ))
      done
      (( _count_compartment++ ))
    done
    (( _count_availability_domain++ ))
  done
  
  # build json list form _json_capacity_reservation array
  _json=$( ${cmd_echo} "${_json_capacity_reservation[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}