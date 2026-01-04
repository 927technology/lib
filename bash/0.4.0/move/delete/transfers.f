move.delete.transfers() {
  # local variables
  local _link=
  local _path_move=~move/move

  # argument variables
  local _host=
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host )
        shift
        _host="${1}"
      ;;
      -p | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  if  [[ ! -z ${_host} ]] && \
      [[ -L ${_path_move}/${_profile}/transfers/${_host} ]]; then
    _link=$( ${cmd_readlink} ${_path_move}/${_profile}/transfers/${_host} )
    ${cmd_rm} --force  ${_path_move}/${_profile}/transfers/${_link} || (( _error_count++ ))
    ${cmd_unlink} ${_path_move}/${_profile}/transfers/${_host} || (( _error_count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}