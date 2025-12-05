template() {
  # dependancies

  # local variables
  local _argument=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a  | --argument )
        shift
        _argument="${1}"
      ;;
    esac
    shift
  done

  # control variables
  # bash does not scope variables in logic structures, you must do it.
  # local loop=

  # main


  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} ${_json}
  return ${_exit_code}
}