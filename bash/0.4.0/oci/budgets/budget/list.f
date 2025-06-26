oci.budgets.budget.list() {
  # prerequisites
  # json/set
  
  # local variables
  local _id=
  local _json="{}"
  local _length=0
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
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
  _json=$( ${cmd_oci} budgets budget list --profile ${_profile} --compartment-id ${_id} | ${cmd_jq} -c '.data' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # set exit string
  _exit_string="${_json}"

  # exit
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}