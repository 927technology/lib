to_epoch() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # main
  while read -r _data; do
    case ${_data} in
      # mm/dd/yyyy hh:mm:ss
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]*[0-9][0-9]*[0-9][0-9]*[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%Y %H:%M:%S" +"%s" "${_data}" ) ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yyyy hh:mm
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]*[0-9][0-9]*[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%Y %H:%M" +%s "${_data}" )    ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yyyy hh
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]*[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%Y %H" +%s "${_data}" )       ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yyyy
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%Y" +%s "${_data}" )          ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yy hh:mm:ss
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9]*[0-9][0-9]*[0-9][0-9]*[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%y %H:%M:%S" +%s "${_data}" ) ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yy hh:mm
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9]*[0-9][0-9]*[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%y %H:%M" +%s "${_data}" )    ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yy hh
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9]*[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%y %H" +%s "${_data}" )       ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      # mm/dd/yy
      [0-9][0-9]/[0-9][0-9]/[0-9][0-9] )
        case $( ${cmd_uname} -s ) in
          Darwin  ) _exit_string=$( ${cmd_date} -j -f "%m/%d/%y" +%s "${_data}" )          ;;
          Linux   ) _exit_string=$( ${cmd_date} --date="${_data}" +"%s" ) ;;
        esac
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      ;;

      * )
        _exit_code=${exit_warn}
    esac
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}