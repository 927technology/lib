move.edit.transfers() {
  # local variables
  local _path_move=~move/move

  # argument variables
  local _host=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host )
        shift
        _host="${1}"
      ;;
    esac
    shift
  done

  # main
  ${cmd_vi} ${_path_move}/transfers/${_host}.json

  # exit
  return ${?}
}