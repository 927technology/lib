bash.accept() {
  shell.lcase () {
  # description

  # dependancies
  # 927/cmd_<platform>.v
  # 927/exits.v

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  
  # local variables
  local _fd=
  local _ip=

  # command arguments variables
  local _interface=localhost
  local _port=8080

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -i | --interface )
        shift
        _interface=${1}
      ;;
      -p | --port )
        shift
        _interface=${1}
      ;;
    esac
    shift
  done


  # main
  # turn on bash listener
  enable accept
  accept -r ${_interface} ${_port} -v ${_fd} && _pid=${!} || (( _error_count++ ))

  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  _exit_string=${_pid}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}
}