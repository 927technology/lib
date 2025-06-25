oci.iam.user.list_groups() {
  # prerequisites
  # json/set
  
  # local variables
  local _id=
  local _json="{}"
  local _json_root="{}"
  local _length=0
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _profile=
  local _userid=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
      -u  | --user-id )
        shift
        _userid="${1}"
      ;;
    esac
    shift
  done

  # main
  _json=$( ${cmd_oci} iam user list-groups --profile ${_profile} --user-id ${_userid} | ${cmd_jq} -c '.data' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # set exit string
  [[ ! -z ${_json} ]] && _exit_string="${_json}" || _exit_string="[]"

  # exit
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}