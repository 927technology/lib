validate_cmd() {
  # local variables
  local _cmd_file=${1}
  local _error_count=0
  local _exit_code=4

  # main
  for cmd in $( /usr/bin/cat ${_cmd_file} | /usr/bin/grep -i ^# | /usr/bin/grep -i ^$ | /usr/bin/awk -F"=" '{print $2}' ); do 
    if [[ ! -f ${cmd} ]]; then
      >&2 /usr/bin/echo x ${cmd}
      (( _error_count++ ))
    fi
  done

  [[ ${_error_count} == 0 ]] && { _exit_code=0; _exit_string=1; } || { _exit_code=2; _exit_string=0; }
  
  # exit
  /usr/bin/echo ${_exit_string}
  return ${_exit_code}
}