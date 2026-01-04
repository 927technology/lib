from_epoch() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # main
  while read -r _data; do
    if [[ $( ${cmd_echo} ${_data} | is_integer ) == ${true} ]]; then
      case $( ${cmd_uname} -s ) in
        Darwin  ) _exit_string=$( ${cmd_date} -j -r ${_data} +"%m/%d/%Y %H:%M:%S" )        ;;
        Linux   ) _exit_string=$( ${cmd_date} --date=@${_data} +"%m/%d/%Y %H:%M:%S" )      ;;
      esac
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
    else
      _exit_string=
      _exit_code=${exit_warn}
    fi

  done    

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}