927.ops.config.new () {
    # description
  # validates ops configuraton
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -jc/--json-candidate json snippit of candidate change

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # arguments variables
  local _candidate=
  local _running=


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | -rs | --json | --running-string )
        shift
        _running="${1}"
      ;;
      -jc | -cs | --json-candidate | --candidate-string )
        shift
        _candidate="${1}"
      ;;
    esac
    shift
  done  

  # main
  if [[ ! -z ${_running} ]] && [[ ! -z ${_candidate} ]]; then
    _running_hash=$( ${cmd_echo}  "${_running}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )
    _candidate_hash=$( ${cmd_echo}  "${_candidate}" | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' 2> /dev/null )

    if [[ ${_running_hash} == ${_candidate_hash} ]]; then
      _exit_code=${exit_ok}
      _exit_string=${false}

    else
        _exit_code=${exit_warn}
        _exit_string=${true}

    fi

  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}