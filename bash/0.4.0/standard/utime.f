utime() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  case $( ${cmd_uname} -s ) in
    Darwin  ) local _exit_string=$(( ( $( date.epoch ) - $( ${cmd_sysctl} -n kern.boottime | ${cmd_awk} -F"," '{print $1}' | ${cmd_awk} '{print $NF}' ) ) / 60 / 60 / 24 )) ;;
    Linux   ) local _exit_string=$(( $( ${cmd_cat} /proc/uptime | ${cmd_awk} -F"." '{print $1}' ) / 60 / 60 / 24 )) ;;
  esac
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
 
  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}



