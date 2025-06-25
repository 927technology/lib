oci.iam.domain.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_domain=0
  local _json="{}"
  local _json_compartments=
  local -a _json_domain=

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

  # main
  # get compartments
  if [[ -z ${_compartments} ]]; then
    _json_compartments=$( ${cmd_oci} iam compartment list --all --compartment-id ${_id} --profile ${_profile} | ${cmd_jq} -c '.data' )
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  fi

  # itterate compartments by id
  for compartment in $( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -r '.[].id'); do
    
    # get domains in each compartment
    for domain in $( ${cmd_oci} iam domain list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # add domain to json
      _json_domain[${_count_domain}]="${domain}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to domain in json
      _json_domain[${_count_domain}]=$( json.set --json ${_json_domain[${_count_domain}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_domain++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_domain array
  _json=$( ${cmd_echo} "${_json_domain[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}