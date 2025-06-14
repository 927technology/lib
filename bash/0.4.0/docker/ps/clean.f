docker.ps.clean () {
  IFS=$'\n' # because IFS sucks
  # description


  # dependancies
  # json/ps
  # json/append

  # local variables
  local _count=0
  local _json=$( docker.ps )

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  for process in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[]' ); do 
    if  [[ $( ${cmd_echo} ${process} | ${cmd_jq} '. | if(.State == "exited") then '${true}' else '${false}' end' ) == ${true} ]]; then
      ${cmd_docker} rm $( ${cmd_echo} ${process} | ${cmd_jq} -r '.ID' ) > /dev/null || (( _error_count++ ))
      _json=$( json.set --json ${_json} --key .[${_count}].clean --value ${true}  )
    
    else
      _json=$( json.set --json ${_json} --key .[${_count}].clean --value ${false} )

    fi

    (( _count++ ))
  done

  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}