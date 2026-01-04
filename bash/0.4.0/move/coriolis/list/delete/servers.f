move.coriolis.list.servers() {
  # local variables
  # none

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  # head space
  ${cmd_echo}
  
  ${cmd_echo} Coriolis - Configured Servers



  ${cmd_printf} "%-2s %-30s : %-20s\n" "D" "Name" "Description"                   
  ${cmd_printf} "------------------------------------------------------------------------\n"
  
  for server in $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.coriolis[]' ); do
    ${cmd_printf} "%-2s %-30s : %-20s\n"                                                                  \
      $( ${cmd_echo} ${server} | ${cmd_jq} -r 'if( .default == 1 ) then "X" else " " end' )               \
      $( ${cmd_echo} ${server} | ${cmd_jq} -r 'if( .name != null ) then .name else "" end' )              \
      $( ${cmd_echo} ${server} | ${cmd_jq} -r 'if( .description != null ) then .description else "" end' ) 
    
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
  
  done

  [[ ${_error_count} == 0 ]] || _exit_code=${exit_ok} && _exit_code=${exit_ok}

  # set tail space
  ${cmd_echo}

  # exit
  return ${_exit_code}
}