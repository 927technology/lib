oci.compute.image.list() {
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
  _json=$( ${cmd_oci} compute image list --all --compartment-id ${compartment} --profile ${_profile} --all | ${cmd_jq} '.data' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  
  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}