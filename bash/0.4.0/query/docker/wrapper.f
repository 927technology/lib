function query.docker {
  # accepts 1 argument url to webserver, returns json

  #local variables
  local _err_count=0
  local _exit_string=
  local _exit_code=${exit_unkn}
  local _json="{}"
  local _output=
  local _verbs=

  # parse command arguments
  ## get verb
  [[ ${1} != "" ]] && _verbs="${1}"
  shift

  ## get additional arguments
  ## none

  #main
  for verb in $( ${cmd_echo} ${_verbs} | ${cmd_sed} 's/,/\ /g' ); do
    _output=
    _output=$( query.docker.resource ${verb} "${@}" ) 
    
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.data.'${verb}' |=.+ '"${_output}" ) 
  done

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.date.pretty |=.+ "'$( date.pretty )'"' ) 
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.date.epoch  |=.+ "'$( date.epoch )'"' ) 
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.error.count |=.+ '${_err_count} ) 
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.run.exit.code   |=.+ '${_exit_code} ) 
  
  _exit_string="${_json}"


  # return
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code} | ${cmd_jq} -c
}
