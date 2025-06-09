hash.md5() {
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
    ${cmd_echo} "${_data}" | ${cmd_md5sum} | ${cmd_awk} '{print $1}'
	  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}