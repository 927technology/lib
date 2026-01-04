hdfs.blocking_decommission() {
  # description

  # variables
  local _count=0
  local _json=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  # none

  # main
  # find blocking files
  for file in $( ${cmd_hdfs} dfsadmin -listOpenFiles -blockingDecommission | ${cmd_grep} .tmp | ${cmd_awk} '{print $3}'); do 
                                      -listOpenFiles
    # add files to json string
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c 'files['${_count}'].path  |=.+ "'"${file}"'"' )
    
    # increment error counter if previous failed
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

    (( _count++ ))
  done

  # add error count to json string
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c 'error.count  |=.+ '${_error_count} )

  # set exit code
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  ${cmd_echo} ${_json}
  return ${exit_code}
}