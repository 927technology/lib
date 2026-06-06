cerner.validate.application() {
  # local variables
  # none

  # argument variables
  local _application=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a  | --application)
        shift
        _application="${1}"
      ;;
    esac
    shift
  done

  # main


}