oci.compute.shape.list() {
  # local variables
  local _json="{}"
  local _id=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

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
  _json=$( ${cmd_oci} compute shape list --compartment-id ${_id} --profile ${_profile} | ${cmd_jq} '.data' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  
  # set exit stringcompute shape list
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}