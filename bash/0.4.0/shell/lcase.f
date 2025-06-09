shell.lcase () {
  # description
  # accepst 1 argument of string and returns the lower case of that string
  #
  ## poisitonal 1 is the string to be converted to lcase

  # dependancies
  # 927/cmd_<platform>.v
  # 927/nagios.v

  # argument variables
  local _string=${1}

  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=

  # parse command arguments
  ## none

  # main
  if  [[ ! -z ${_string} ]]; then  
    # set exit string to lcase
    _exit_string=$( ${cmd_echo} ${_string} | ${cmd_awk} -F"|" '{print tolower($1)}' )

    # set exit code
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  else
    # keep exit string if empty
    ${cmd_echo} ${_string}

    # set exit code
    exit_code=${exit_crit}
  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}