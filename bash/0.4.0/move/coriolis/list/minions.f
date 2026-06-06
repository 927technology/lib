move.coriolis.list.minions() {
  #_description: Displays cached coriolis minions
  #_filter: false
  #_name: false
  #_arguments: --distro,--family,--output,--profile,--version
  #_output: distro,family,id,version

  # local variables
  local _json="{}"
  local _path=~move/move
  local _os_distro=
  local _os_family=
  local _os_version=

  # argument variables
  local _output=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -d | --distro )
        shift
        _os_distro="${1}"
      ;;
      -f | --family )
        shift
        _os_family="${1}"
      ;;
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -V | --version )
        shift
        _os_version="${1}"
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile move.set.profile --name <profile name>"; return ${exit_crit}; }


  if  [[ ! -z ${_os_distro}   ]] && \
      [[ ! -z ${_os_family}   ]] && \
      [[ ! -z ${_os_version}  ]]; then

    _json=$(
      move.coriolis.list.endpoints.destination.options --profile ${_profile} --type minion | ${cmd_jq} '
        [
          .[] | 
            select( .name | startswith( "minion" ) ) | 
            if( .name | split(" ")[0] | split("-") | length == 3 ) then . |
              { 
                "id": .id,
                "os": { 
                  "distro": .name | split("-")[1] | split("_")[0],
                  "family":  .os_type, 
                  "version": .name | split("-")[1] | split("_")[1] 
                }, 
                "type": .name | split("-")[0], 
                "version": .name | split("-")[2] | split(" ")[0] 
              }
            else
              empty
            end | 
          select((( 
              .os.family == "'"${_os_family}"'" 
            ) and  
              .os.version == "'"${_os_version}"'" 
            ) and 
              .os.distro == "'"${_os_distro}"'" 
          ) 
        ] |
        sort_by(
          .os.family, 
          .os.distro, 
          .os.version, 
          .version 
        )[-1]
      '
    )

    [[ ${_json} == null ]] && { _json= ; (( _error_count++ )); }

  else
    _json=
    (( _error_count++ ))

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      distro             ) ${cmd_echo} ${_json} | ${cmd_jq} -r '"\(.os.distro)_\(.os.version)"' ;;
      family             ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.os.family'                     ;;
      version            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.version'                       ;;
      id                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.id'                            ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}




