function query {
  # accepts 1 argument url to webserver, returns json

  #local variables
  local _component=
  local _err_count=0
  local _exit_string=
  local _exit_code=${exit_unkn}
  local _json="{}"
  local _osquery=${false}
  local _output=
  local _resource_count=0
  local _resource_length=0
  local _resources=

  # parse command arguments
  ## get component
  [[ ${1} != "" ]] && _component="${1}"
  shift
  [[ ${1} != "" ]] && _resources="${1}"
  shift

  ## get additional arguments
  ## none

  #main
  for resource in $( ${cmd_echo} ${_resources} | ${cmd_sed} 's/,/\ /g' ); do
    # reset variables to default
    _exit_code=${exit_unkn}
    _output=
    _resource_length=0

    # use osqueryi if available
    [[ -f ${cmd_osqueryi} ]] && _osquery=${true}

    if [[ ${_osquery} == ${true} ]]; then
      _output=$( eval query.${_component}.resource ${resource} -o ) 

      _exit_code=${?}
    
    else
      _output=$( eval query.${_component}.resource ${resource} ) 

      _exit_code=${?}
    fi

    # get list length
    _resource_length=$( ${cmd_echo} ${_output} | ${cmd_jq} '. | length' )

    [[ ${_exit_code} != ${exit_ok} ]] && (( _err_count++ ))

    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.data.'${resource}' |=.+ '"${_output}" ) 
    
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.resource['${_resource_count}'].exit.code |=.+ '${_exit_code} ) 
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.resource['${_resource_count}'].name      |=.+ "'"${resource}"'"' )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.resource['${_resource_count}'].length    |=.+ '"${_resource_length}" ) 

    (( _resource_count++ )) 
  done

  # reuse variable for global exit
  _exit_code=${exit_unkn}

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # output run status
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.date.pretty |=.+ "'$( date.pretty )'"' ) 
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.date.epoch  |=.+ "'$( date.epoch )'"' ) 
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.error.count |=.+ '${_err_count} ) 
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.osquery     |=.+ '${_osquery} ) 
  
  _exit_string="${_json}"


  # return
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code} | ${cmd_jq} -c
}
