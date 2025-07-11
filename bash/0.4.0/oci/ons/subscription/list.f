oci.ons.subscription.list() {
  # dependancies
  # oci/compartments/compartment/list.f

  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_subscription=0
  local _compartment_id=
  local _json="{}"
  local -a _json_subscription=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

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
  # itterate compartments
  for compartment in $( oci.iam.compartment.list --profile ${_profile} --id ${_id} | ${cmd_jq} -c '.[]' ); do
   
    # get compartment id
    _compartment_id=$( ${cmd_echo} ${compartment} | ${cmd_jq} -r '.id' )

      # itterate subscriptions
      for subscription in $( ${cmd_oci} ons subscription list --compartment-id ${_compartment_id} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do

        # add alert-rule array
        _json_subscription[${_count_subscription}]=${subscription}
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
        
        # # add compartment to subscription array
        _json_subscription[${_count_subscription}]=$( json.set --json ${_json_subscription[${_count_subscription}]} --key .compartment --value "${compartment}" )
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
        (( _count_subscription++ ))
      done

    (( _count_compartment++ ))
  done
  
  # build json list form _json_console_history array
  _json=$( ${cmd_echo} "${_json_subscription[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}