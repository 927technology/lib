oci.iam.iam_work_request.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_iam_work_request=0
  local _json="{}"
  local _json_compartments=
  local -a _json_iam_work_request=

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
    # get iam_work_requests in each compartment

    for iam_work_request in $( ${cmd_oci} iam iam-work-request list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # add iam_work_request to json
      _json_iam_work_request[${_count_iam_work_request}]="${iam_work_request}"
      
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add compartment to iam_work_request in json
      _json_iam_work_request[${_count_iam_work_request}]=$( json.set --json ${_json_iam_work_request[${_count_iam_work_request}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_iam_work_request++ ))
    done
    (( _count_compartment++ ))
  done
  echo 40
  # build json list form _json_iam_work_request array
  _json=$( ${cmd_echo} "${_json_iam_work_request[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}