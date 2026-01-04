hdfs.version() {
  # description

  # variables
  local _json=
  local _hdfs=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  # none

  # main
  # get output from hdfs
  _hdfs=$( ${cmd_hdfs} version | ${cmd_grep} ^Hadoop | ${cmd_awk} '{print $2}'  ) || (( _error_count++ ))

  # get hadoop version
  _json=$( json.set --json ${_json} --key .hadoop.version --value "$( ${cmd_echo} ${_hdfs} | ${cmd_awk} -F"-" '{print $1}' )" ) || (( _error_count++ ))

  # get cdh version
  _json=$( json.set --json ${_json} --key .cdh.version --value "$( ${cmd_echo} ${_hdfs} | ${cmd_awk} -F"-" '{print $2}' | ${cmd_sed} 's/cdh//g' )" ) || (( _error_count++ ))


  # add error count to json string
  _json=$( json.set --json ${_json} --key .error.count --value ${_error_count} )

  # set exit code
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  ${cmd_echo} ${_json}
  return ${exit_code}
}