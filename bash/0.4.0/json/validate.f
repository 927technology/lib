json.validate () {
  # local variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local _tag=json.validate

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
    esac
    shift
  done

  # main
  if [[ ! -z "${_json}" ]]; then
    ${cmd_echo} "${_json}" | ${cmd_jq} > /dev/null 2>&1
    
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log --tag ${_tag} --message "json validated successfully"
      _exit_code=${exit_ok}
      # _exit_string=${true}

    else
      shell.log --tag ${_tag} --message "json validated unsuccessfully"
      _exit_code=${exit_crit}
      # _exit_string=${false}

    fi
  fi

  # exit
  return ${_exit_code}
}