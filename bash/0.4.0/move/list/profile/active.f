move.list.profile.active() {
  # usage
  # -p | --profile              :set the move profile, uses ${MOVE_PROFILE} by default
  # -o | --output               :filters output
  #     coriolis_endpoints      :coriolis endpoints as json array
  #     name                    :profile name as string
  #     vsphere_endpoints       :vsphere endpoints as json array
  #     windows_virtio_zip_url  :windows virtio zip url path as string

  # local variables
  local _json=
  local _path=~move/move
  local _type=

  # argument variables
  local _profile=${MOVE_PROFILE}
  local _output=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name | -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -t | --type )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in 
          c | coriolis  ) _type=coriolis  ;;
          v | vsphere   ) _type=vsphere   ;;
        esac
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && return ${exit_crit}

  _json=$( ${cmd_cat} /usr/local/etc/move/connect.json 2>/dev/null | ${cmd_jq} -c '.[] | select( ( .name == "'"${_profile}"'" ) and .enable == '${true}' )' && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  if [[ ! -z ${_output} ]]; then
    case ${_type} in
      coriolis )
        case ${_output} in
          all                     ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .coriolis[] | select( .enable == '${true}' ) | if( . ) then . else empty end ]' ;;
          auth                    ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .coriolis[] | select( .enable == '${true}' ) | if( .auth ) then .auth else empty end ]' ;;
          endpoints               ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .coriolis[] | select( .enable == '${true}' ) | if( .endpoint ) then .endpoint else empty end ]' ;;
          migr_map                ) ${cmd_echo} ${_json} | ${cmd_jq} -c   '.coriolis[] | select( .enable == '${true}' ) | if( .migr_map ) then .migr_map else empty end' ;;
          vault_credential        ) ${cmd_echo} ${_json} | ${cmd_jq} -r   '.coriolis[] | select( .enable == '${true}' ) | if( .auth.vault.credential.name ) then .auth.vault.credential.name else empty end' ;;

        esac
      ;;
      vsphere )
        case ${_output} in
          all                     ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .vsphere[] | select( .enable == '${true}' ) | if( . ) then . else empty end ]' ;;
          auth                    ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .vsphere[] | select( .enable == '${true}' ) | if( .auth ) then .auth else empty end ]' ;;
          endpoints               ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .vsphere[] | select( .enable == '${true}' ) | if( .endpoint ) then .endpoint else empty end ]' ;;
          vault_credential        ) ${cmd_echo} ${_json} | ${cmd_jq} -r   '.vsphere[] | select( .enable == '${true}' ) | if( .auth.vault.credential.name ) then .auth.vault.credential.name else empty end' ;;

        esac
      ;;
      * )
        case ${_output} in
          coriolis_endpoints      ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .coriolis[]  | select( .enable == '${true}' ).endpoint ]' ;;
          vsphere_endpoints       ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .vsphere[]   | select( .enable == '${true}' ).endpoint ]' ;;
          name                    ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                         ;;
          # rapid_key | key         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '. | select( .rapid[].enable == 1 ) | if( .rapid[0].key ) then .rapid[0].key else empty end' ;;
          # rapid_secret | secret   ) ${cmd_echo} ${_json} | ${cmd_jq} -r '. | select( .rapid[].enable == 1 ) | if( .rapid[0].secret ) then .rapid[0].secret else empty end' ;;
          # rapid_alternate_id | alternate_id ) ${cmd_echo} ${_json} | ${cmd_jq} -r '. | select( .rapid[].enable == 1 ) | if( .rapid[0].alternate_id ) then .rapid[0].alternate_id else empty end' ;;
          # rapid_vault_title | vault_title ) ${cmd_echo} ${_json} | ${cmd_jq} -r '. | select( .rapid[].enable == 1 ) | if( .rapid[0].vault_title ) then .rapid[0].vault_title else empty end' ;;
          windows_virtio_zip_url  ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .windows_virtio_zip_url ) then .windows_virtio_zip_url else blank end'       ;;
          rapid                   ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ if( .auth.rapid ) then .auth.rapid else empty end ]' ;;
          rapid_key               ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .auth.rapid.key ) then .auth.rapid.key else empty end' ;;
          rapid_secret            ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .auth.rapid.secret ) then .auth.rapid.secret else empty end' ;;
          vault                   ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .auth.vault.name ) then .auth.vault.name else empty end' ;;

        esac
      ;;
    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}