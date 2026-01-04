lcase() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  while read -r _data; do
    _exit_string="$( ${cmd_echo} "${_data}" | ${cmd_awk} -F"\n" '{print tolower($1)}' )"
    _exit_code=${?}
  done

  # exit
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}