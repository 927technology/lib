927.ops.config.pull.secretservice () {
  # description
  # 

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/nagios.v
  # 927/secretservice.l
  # json/validate.f

  # argument variables
  # none

  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  local _secret_name=
  local _secret_note=
  local _secret_role=
  local _secret_service_account=
  local _secret_type=
  local _secret_value=
  local _tag=927.ops.config.pull.secretservice

  # parse command arguments
  # none

  # main
  for type in users keys passwords tlscerts tlskeys; do

    _json=$( 927.secretservice.get.bitwarden.${type} )

    if [[ ${type} == users ]]; then
      _secret_service_account=$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[] | select(.key == "user_service-account_secret").value' )
    fi

    for secret in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[]' ); do 
      # key naming
      _secret_type=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.key | split("_")[0]' )
      _secret_name=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.key | split("_")[1]' )
      _secret_role=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.key | split("_")[2]' )
      
      # note
      _secret_note=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.note' )

      # value
      _secret_value=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.value' )

      ${cmd_mkdir} -p /home/${_secret_service_account}/${_secret_role}/${_secret_type}
      # echo name $_secret_name
      # echo role $_secret_role
      # echo type $_secret_type
      # echo value $_secret_value
      ${cmd_echo} "${_secret_value}" > /home/${_secret_service_account}/${_secret_role}/${_secret_type}/${_secret_name}

    done 
  done
}
