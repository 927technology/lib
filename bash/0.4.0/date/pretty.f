date.pretty() {
  # description
  # accepts no args.  returns date in YYYY-MM-DD_HH:MM:SS
  
  # local variables
	# none

  # control variables
	local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  case $( ${cmd_uname} -s ) in
    Darwin  ) _exit_string=$( ${cmd_date} -j +'%Y-%m-%d_%H:%M:%S' )  ;;
    Linux   ) _exit_string=$( ${cmd_date}    +'%Y-%m-%d_%H:%M:%S' )  ;;
  esac
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}