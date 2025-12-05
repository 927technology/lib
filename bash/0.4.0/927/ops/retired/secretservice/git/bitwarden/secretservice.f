927.ops.secretservice.get.secrets () {
  # description
  # retrieves secrets from secrets provider.
  # writes secrets in /opt/secrets based on $ROLES provided

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/nagios.v
  # 927/secretservice.l
  # shell.l
  # json/validate.f

  # because IFS sucks
  IFS=$'\n'  

  # argument variables
  # none

  # local variables
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  local _json_secret="{}"
  local _secret_name=
  local _secret_note=
  local _secret_role=
  local _secret_type=
  local _secret_value=
  local _tag=927.ops.secretservice.get.bitwarden.secrets

  # parse command arguments
  # none

  # main
  # allow for multiple roles
  for role in $( ${cmd_echo} ${ROLES} | ${cmd_sed} 's/,/\n/g' ); do

    for type in users keys passwords secrets tlscerts tlskeys; do
      _json_secret=$( 927.secretservice.get.${SECRET_PROVIDER}.${type} )

      for secret in $( ${cmd_echo} "${_json_secret}" | ${cmd_jq} -c '.[]' ); do 
        _json="{}"
        _secret_type=
        _secret_name=
        _secret_role=
        _secret_value=

        # type name
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.name |=.+ "'"${type}"'"' )

        # key naming
        _secret_type=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.key | split("_")[0]' )
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.type |=.+ "'"${_secret_type}"'"' )

        _secret_name=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.key | split("_")[1]' )
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.name |=.+ "'"${_secret_name}"'"' )

        _secret_role=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.key | split("_")[2]' )
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.role |=.+ "'"${_secret_role}"'"' )

        # note
        _secret_note=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.note' | ${cmd_sed} 's/\ /_/g' )
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.note |=.+ "'"${_secret_note}"'"' )

        # value
        _secret_value=$( ${cmd_echo} "${secret}" | ${cmd_jq} -r '.value' )
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.value |=.+ "REDACTED"' )

        # only use secrets for my role
        if [[ ${_secret_role} == ${role} ]]; then

          # populate secret files
          [[ ! -d /opt/secrets/${_secret_role}/${_secret_type} ]] && ${cmd_mkdir} -p /opt/secrets/${_secret_role}/${_secret_type}
          ${cmd_echo} "${_secret_value}" > /opt/secrets/${_secret_role}/${_secret_type}/${_secret_name}
          _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.written |=.+ "'"/opt/secrets/${_secret_role}/${_secret_type}/${_secret_name}"'"' )

          # create service accounts
          if [[ ${type} == users ]]; then
            
            if [[ ${_secret_name} == service-account ]]; then

              if [[ $( ${cmd_getent} passwd ${_secret_role} | ${cmd_grep} -c ^${_secret_role} ) == 0 ]]; then
                ${cmd_adduser} ${_secret_role} 2>&1 >/dev/null

              fi
            fi
          fi
        fi

        shell.log --tag ${_tag} --remote ${LOG_SERVER} --json "${_json}"
      
      done
    done
  done
}