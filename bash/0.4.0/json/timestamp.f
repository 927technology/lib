json.timestamp () {
  # description
  # creates ops hosts stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # date/epoch.f
  # date/pretty.f
  # json/validate.f

  
  # argument variables
  ## none


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # variables
  local _json="{}"
  local _output=
  local _date_epoch=$( date.epoch )
  local _date_pretty=$( date.pretty )

  # parse command arguments
  ## none

  # main
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.date.epoch          |=.+ '"${_date_epoch}" )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.date.pretty         |=.+ "'"${_date_pretty}"'"' )


  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}