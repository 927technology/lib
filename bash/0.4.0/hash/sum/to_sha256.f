to_sha256() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _hash=

  while read -r _data; do
    if [[ -f ${_data} ]]; then
      _hash=$( ${cmd_cat} "${_data}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
    
    else
      _hash=$( ${cmd_echo} "${_data}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
    
    fi 
    
    if [[ ${?} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
      _exit_string=${_hash}
    else  
      _exit_code=${exit_ok}
      _exit_string=${false}
    fi
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}