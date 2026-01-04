move.set.transfers() {
  # local variables
  local _continue=${false}
  local _json=
  local _lead_time=30
  local _path=~move/move

  # argument variables
  local _filter=
  local _name=
  local _id=
  local _key=
  local _key_prefix=
  local _key_suffix=
  local _profile=
  local _value=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local host=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} ${1} | lcase )
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -i | --id )
        shift
        _id="${1}"
      ;;
      -k | --key )
        shift
        _key="${1}"
      ;;
      -p | --profile )
        shift
        _profile="${1}"
      ;;
      -v | --value )
        shift
        _value="${1}"
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  if    [[ ! -z ${_name} ]]; then
    _json=$( move.list.transfers --name ${_name} --profile ${_profile} && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ ! -z ${_filter} ]]; then
    _json=$( move.list.transfers --filter ${_filter} --profile ${_profile} && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  else
    _exit_code=${exit_crit}
    return ${_exit_code}

  fi

  # itterate hosts in _json
  for host in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[]' ); do

    # check for lists passed in
    if  [[ $( ${cmd_echo} "${_key}" | ${cmd_grep} -c ]$ ) == 0 ]] ; then
      _key_suffix=$( ${cmd_echo} "${_key}" | ${cmd_awk} -F"." '{print $NF}' )
      _key_prefix=$( ${cmd_echo} "${_key}" | ${cmd_sed} 's/'${_key_suffix}'//g' | ${cmd_sed} 's/.$//g' )

      # check if key exists
      if  [[ $( ${cmd_echo} "${host}" | ${cmd_jq} $( [[ -z ${_key_prefix} ]] && ${cmd_echo} . || ${cmd_echo} ${_key_prefix} )' | if( has("'${_key_suffix}'") ) then '${true}' else '${false}' end' ) == ${true} ]] && \
          [[ $( ${cmd_echo} "${host}" | ${cmd_jq} "${_key}"' | if( type=="array" ) then '${true}' else '${false}' end' ) == ${false} ]]; then

        # is date
        if [[ $( ${cmd_echo} "${_key}" | ${cmd_grep} -c .date$ ) > 0 ]]; then
            # test date
            ${cmd_echo} "${_value}" | to_epoch >/dev/null 2>&1

            # is date
            if [[ ${?} == ${exit_ok} ]]; then
              host=$( json.set --json "${host}" --key "${_key}" --value $( ${cmd_echo} "${_value}" | to_epoch ) )

            # not date  
            else  
              shell.log "${FUNCNAME}(${_profile}) - [SYNTAX]  VM: $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.name' ), ERROR: \"${_value}"\" is not a properly formatted date string \"mm/dd/yyyy HH/MM/SS\"

            fi

        # not date
        else
          host=$( json.set --json "${host}" --key "${_key}" --value "${_value}" )

        fi

        # set exit code    
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

        # output to file
        shell.log "${FUNCNAME}(${_profile}) - [SETTING]  VM: $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.name' ), KEY: "${_key}", VALUE: ${_value}"
        ${cmd_echo} "${host}" > ${_path}/${_profile}/transfers/$( ${cmd_echo} "${host}" | ${cmd_jq} -r '.name' )
       
      else 
        # set exit code    
        _exit_code=${exit_crit}

      fi
    fi

  done
  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}