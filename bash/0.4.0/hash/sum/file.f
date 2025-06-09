hash.sum.file () {
  # description
  # calculates hash sum of provided provided at ${1}

  # dependancies
  # 927/cmd_<platform>.v
  # 927/nagios.v

  # argument variables
  local _file=${1}
  
  # local variables
  local _algorithm=sha256
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _hash=
  local _tag=hash.sum.file
 
  # parse command arguments
  # none

  # main
  if [[ -f ${_file} ]]; then
    case ${_algorithm} in 
      sha256 )
        _hash=$( ${cmd_sha256sum} ${_file} | ${cmd_awk} '{print $1}' )
      ;;
    esac

    if [[ ${?} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
    else
      _exit_code=${exit_crit}
    fi

    # logging string status
    shell.log --tag ${_tag} --message "offered file is present ${_hash}"
    
  else
    # logging string status
    shell.log --tag ${_tag} --message "offered string is not present"

    _exit_code=${exit_crit}
  fi
  # exit
  ${cmd_echo} ${_hash}

  # return _exit_code
  return ${_exit_code}
}