hash.sum.string () {
  # description
  # calculates hash sum of string provided at ${1}

  # dependancies
  # 927/cmd_<platform>.v
  # 927/nagios.v

  # argument variables
  local _string=${1}
  
  # local variables
  local _algorithm=sha256
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _hash=
  local _tag=hash.sum.string
 
  # parse command arguments
  # none

  # main
  if [[ ! -z ${_string} ]]; then
    case ${_algorithm} in 
      sha256 )
        _hash=$( ${cmd_echo} ${_string} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
      ;;
    esac

    if [[ ${?} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
    else
      _exit_code=${exit_crit}
    fi

    # logging string status
    shell.log --tag ${_tag} --message "offered string is not empty ${_hash}"
    
  else
    # logging string status
    shell.log --tag ${_tag} --message "offered string is empty"

    _exit_code=${exit_crit}
  fi
  # exit
  ${cmd_echo} ${_hash}

  # return _exit_code
  return ${_exit_code}
}