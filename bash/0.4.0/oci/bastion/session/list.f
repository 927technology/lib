oci.bastion.session.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_bastion=0
  local _count_session=0
  local _json="{}"
  local -a _json_session=
  local _id_bastion=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json_bastion=

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
  # get namespaces
  _json_bastion=$( oci.bastion.bastion.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c )

  # itterate bastions by id
  for bastion in $( ${cmd_echo} ${_json_bastion} | ${cmd_jq} -c '.[]' ); do
    # get the availability domain name
    _id_bastion=$( ${cmd_echo} ${bastion} | ${cmd_jq} -r '.id')

    # get sessions in each availability domain
    for session in $( ${cmd_oci} bastion session list --profile ${_profile} --session-namespace-id ${_id_bastion} | ${cmd_jq} -c '.data[]' ); do
      # add session to json
      _json_session[${_count_session}]="${session}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add session namespace to session in json
      _json_session[${_count_session}]=$( json.set --json ${_json_session[${_count_session}]} --key .\"session-namespace\" --value "$( ${cmd_echo} ${_json_bastion} | ${cmd_jq} -c '.['${_count_bastion}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_session++ ))
    done
    (( _count_bastion++ ))
  done
  
  # build json list form _json_session array
  _json=$( ${cmd_echo} "${_json_session[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}