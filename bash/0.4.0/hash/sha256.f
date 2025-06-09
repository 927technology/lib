hash.sha256() {
	# description
	
	# local variables
	# none

  # control variables
	local _exit_code=${exit_unkn}
  local _exit_string=

	# parse arguments
	# none

	# main
  while read -r _data; do
    if [[ $( ${cmd_echo} ${_data} | is_file ) == ${true} ]]; then
      _exit_string=$( ${cmd_cat} "${_data}"   | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
      
    else
      _exit_string=$( ${cmd_echo} "${_data}"  | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
	  
    fi
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}