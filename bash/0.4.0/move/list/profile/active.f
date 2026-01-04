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
        _profile="${1}"
      ;;
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  _json=$( ${cmd_cat} /usr/local/etc/move/connect.json 2>/dev/null | ${cmd_jq} -c '.[] | select( ( .name == "'"${MOVE_PROFILE}"'" ) and .enable == '${true}' )' && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      coriolis_endpoints      ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .coriolis[]  | select( .enable == '${true}' ).endpoint ]' ;;
      vsphere_endpoints       ) ${cmd_echo} ${_json} | ${cmd_jq} -c '[ .vsphere[]   | select( .enable == '${true}' ).endpoint ]' ;;
      name                    ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                         ;;
      windows_virtio_zip_url  ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.windows_virtio_zip_url'       ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}