oci.iam.user.list() {
  # dependancies
  # oci/iam/user/list_groups
  # oci/iam/user/oauth2-credential/list
  # oci/iam/auth_token/list

  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_compartment=0
  local _count_user=0
  local _json="{}"
  local -a _json_user=
  local _json_user_groups=
  local _userid=

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
    
    # get users in each compartment
    for user in $( ${cmd_oci} iam user list --compartment-id ${compartment} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do
      # get user id
      _userid=$( ${cmd_echo} ${user} | ${cmd_jq} -r '.id' )

      # add user to json
      _json_user[${_count_user}]="${user}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
      # add user auth-token to user in json
      _json_user[${_count_user}]=$( json.set --json ${_json_user[${_count_user}]} --key .\"auth-token\" --value "$( oci.iam.auth_token.list --profile ${_profile} --user-id ${_userid} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add compartment to user in json
      _json_user[${_count_user}]=$( json.set --json ${_json_user[${_count_user}]} --key .compartment --value "$( ${cmd_echo} ${_json_compartments} | ${cmd_jq} -c '.['${_count_compartment}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add customer_secret_key to user in json
      _json_user[${_count_user}]=$( json.set --json ${_json_user[${_count_user}]} --key .\"customer-secret-key\" --value "$( oci.iam.customer_secret_key.list --profile ${_profile} --user-id ${_userid} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}


      # add user groups to user in json
      _json_user[${_count_user}]=$( json.set --json ${_json_user[${_count_user}]} --key .groups --value "$( oci.iam.user.list_groups --profile ${_profile} --user-id ${_userid} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add user oauth2-credential to user in json
      _json_user[${_count_user}]=$( json.set --json ${_json_user[${_count_user}]} --key .\"oauth2-credential\" --value "$( oci.iam.user.oauth2-credential.list --profile ${_profile} --user-id ${_userid} )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_user++ ))
    done
    (( _count_compartment++ ))
  done
  
  # build json list form _json_user array
  _json=$( ${cmd_echo} "${_json_user[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}