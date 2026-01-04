move.set.network.map() {
  # local variables
  local _path=~move/move

  # argument variables
  local _key=
  local _key_prefix=
  local _key_suffix=
  local _network=
  local _value=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -k | --key )
        shift
        _key="${1}"
      ;;
      -n | --network )
        shift
        _network="${1}"
      ;;
      -v | --value )
        shift
        _value="${1}"
      ;;
    esac
    shift
  done

  # main
  echo -----
  _json=$( ${cmd_cat} ${_path}/networks/${_network}.json | ${cmd_jq} -c )

  echo -----

  # check for lists passed in
  if  [[ $( ${cmd_echo} ${_key} | ${cmd_grep} -c ]$ ) == 0 ]] ; then

    _key_suffix=$( ${cmd_echo} ${_key} | ${cmd_awk} -F"." '{print $NF}' )
    _key_prefix=$( ${cmd_echo} ${_key} | ${cmd_sed} 's/'${_key_suffix}'//g' | ${cmd_sed} 's/.$//g' )
   

    # check if key exists
    if  [[ $( ${cmd_echo} ${_json} | ${cmd_jq} $( [[ -z ${_key_prefix} ]] && ${cmd_echo} . || ${cmd_echo} ${_key_prefix} )' | if( has("'${_key_suffix}'") ) then '${true}' else '${false}' end' ) == ${true} ]] && \
        [[ $( ${cmd_echo} ${_json} | ${cmd_jq} ${_key}' | if( type=="array" ) then '${true}' else '${false}' end' ) == ${false} ]]; then

      _json=$( json.set --json ${_json} --key ${_key} --value ${_value} )

      # set exit code    
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # output to screen
      ${cmd_echo} ${_json} | ${cmd_jq}

      # output to file
      ${cmd_echo} ${_json} | ${cmd_jq} > ${_path}/networks/${_network}.json

    else 
      # set exit code    
      _exit_code=${exit_crit}

    fi

  else
      # set exit code    
    _exit_code=${exit_crit}

  fi

  return ${_exit_code}
}