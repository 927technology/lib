date.epoch() {
	# description
	# accepts no args.  returns date in number of seconds since January 1, 1970
	
	# local variables
	# none

  # control variables
	local _exit_code=${exit_unkn}
  local _exit_string=

	# parse arguments
	# none

	# main
	case $( ${cmd_uname} -s ) in
		Darwin  ) _exit_string=$( ${cmd_date} -j +"%s" )        ;;
		Linux   ) _exit_string=$( ${cmd_date}    +"%s" )        ;;
	esac
	[[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}