shell.is_bash() {
  # local variables
  local _version=
  local _version_major=
  local _version_minor=
  local _version_patch=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -v  | --version )
        shift
        _version="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ ! -z ${_version} ]]; then
    _version_major=$( ${cmd_echo} ${_version} | ${cmd_awk} -F"." '{print $1}' )
    _version_minor=$( ${cmd_echo} ${_version} | ${cmd_awk} -F"." '{print $2}' )
    _version_patch=$( ${cmd_echo} ${_version} | ${cmd_awk} -F"." '{print $3}' )
  fi

  if [[ ! -z ${_version_major} ]] && [[ ! -z ${_version_minor} ]] && [[ ! -z ${_version_patch} ]]; then
    _exit_string=$( shell.get_version | ${cmd_jq} 'if( try( .detected ) == 1 and try( .value ) == "bash" and try( .version.major ) <= '${_version_major}' and try( .version.minor ) <= '${_version_minor}' and try( .version.patch ) <= '${_version_patch}' ) then '${true}' else '${false}' end' )

  elif [[ ! -z ${_version_major} ]] && [[ ! -z ${_version_minor} ]]; then
    _exit_string=$( shell.get_version | ${cmd_jq} 'if( try( .detected ) == 1 and try( .value ) == "bash" and try( .version.major ) <= '${_version_major}' and try( .version.minor ) <= '${_version_minor}' ) then '${true}' else '${false}' end' )

  elif [[ ! -z ${_version_major} ]]; then
    _exit_string=$( shell.get_version | ${cmd_jq} 'if( try( .version.major ) <= '${_version_major}' ) then '${true}' else '${false}' end' )

  else
    _exit_string=$( shell.get_version | ${cmd_jq} 'if( try( .detected ) == 1 and try( .value ) == "bash" ) then '${true}' else '${false}' end' )
  
  fi

  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}