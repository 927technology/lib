927.ops.config.pull () {
  # description
  # pulls ops configuration from remote source
  # accepts 2 arguments -
  ## -u /--url url that hosts the configuraiton
  ## -p / --path path to save the confguration to

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # arguments variables
  local _group=root
  local _mode=550
  local _owner=nts_ms
  local _path=/ops/management/configuration

  # control variables
  local _candidate_json="{}"
  local _candidate_hash=
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json="{}"
  local _json_validate=${false}
  local _replace=${false}
  local _running_json="{}"
  local _running_hash=
  

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -g | --group )
        shift
        _group="${1}"
      ;;
      -m | --mode )
        shift
        _mode="${1}"
      ;;
      -o | --owner )
        shift
        _owner="${1}"
      ;;
      -p | --path )
        shift
        _path="${1}"
      ;;
    esac
    shift
  done  

  # main
  # make output path
  [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path}



  # loop for configurations pulled
  for type in configuration infrastructure; do
    # configuration variables
    _candidate_json=$(  ${cmd_curl} -s ${URL}/${type}.json | ${cmd_jq} -c )
    
    # get running json if present
    if [[ -f ${_path}/${type}.json ]]; then
      _running_json=$( ${cmd_cat} ${_path}/${type}.json )
    fi

    # validate candidate json
    if [[ $( json.validate -j ${_candidate_json} ) == ${true} ]]; then
      _json_validate=${true}
    fi

    if [[ ${_json_validate} == ${true} ]]; then

      # get configuration hashes
      if [[ -f ${_path}/${type}.json ]]; then
        _running_hash=$(    ${cmd_sha256sum} ${_path}/${type}.json                    | ${cmd_awk} '{print $1}' 2> /dev/null )
      fi

      _candidate_hash=$(  ${cmd_echo}     "${_candidate_json}"   | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )

      if [[ ${_running_hash} != ${_candidate_hash} ]]; then
        ${cmd_echo} ${_candidate_json} > ${_path}/${type}.json
        _replace=${true}
      fi
    fi
    
    # add statuses to json
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.'${type}'.validate   |=.+ '${_json_validate} )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.'${type}'.running    |=.+ "'"${_running_hash}"'"' )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.'${type}'.candidate  |=.+ "'"${_candidate_hash}"'"' )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.'${type}'.replace    |=.+ '${_replace} )
  done

  # set file owner:group
  if [[ ! -z ${_group} ]] && [[ ! -z ${_owner} ]]; then
    ${cmd_chown} -R ${_owner}:${_group} ${_path}
  fi

  # set file mode
  if [[ ! -z ${_mode} ]]; then
    ${cmd_chmod} -R ${_mode} ${_path}
  fi


  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # set exit_string
  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -c )


  # exit
  ${cmd_echo} ${_exit_string}

  return ${_exit_code}
}