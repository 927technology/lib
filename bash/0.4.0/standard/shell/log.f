shell.log() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables

  # argument variables
  local _naemon=${false}
  local _string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -N | --naemon )
        _naemon=${true}
      ;;
      -s | --string )
        shift
        _string="${1}"
      ;;
      * )
        _string="${1}"
      ;;
     esac
    shift
  done


  # main
  if [[ ${_naemon} == ${true} ]]; then
    ${cmd_echo} ${_string}
    
  else
    >&2 ${cmd_echo} $( date.pretty ) ${_string}
    if  [[ ! -z ${LOGFILE} ]] && \
        [[ -d $( ${cmd_echo} ${LOGFILE} | ${cmd_awk} 'BEGIN{FS=OFS="/"}{NF--; print}' ) ]]; then
      ${cmd_echo} $( date.pretty ) ${_string} >> ${LOGFILE}
    fi
  fi

  # exit
  return ${_exit_ok}
}