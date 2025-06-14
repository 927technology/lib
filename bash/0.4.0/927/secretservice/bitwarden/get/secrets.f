927.secretservice.bitwarden.get.secrets () {
  # description
  # retrieves bitwarden tls certs

  # dependancies
  # variables/cmd/<distro>.v
  # variables/bools.v
  # variables/exits.v
  # json/validate.f

  # argument variables
  local _json="{}"
  local _verbose=${false}
  
  # local variables
  local _token=${false}
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _tag=927.secretservice.get.bitwarden.secrets

  # parse command arguments
  # none

  # main
  # check bws access token is present as an environmental variable
  [[ ! -z ${BWS_ACCESS_TOKEN} ]] && _token=${true}

  # print arguments to syslog
  shell.log --tag ${_tag} --message "token:${_token} provider:bitwarden secret_type:secret"

  if [[ ${_token} == ${true} ]]; then
    _json=$( ${cmd_bws} secret list | ${cmd_jq} '.[] | select(.secret | startswith("secret"))' 2>/dev/null )

    # validate success
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log --tag ${_tag} --message "secrets retrieved successfully"

    else 
      shell.log --tag ${_tag} --message "secrets retrieved unsuccessfully"
      (( _error_count++ ))
    fi

    # validate json
    json.validate --json "${_json}"
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log --tag ${_tag} --message "secrets json validated successfully"

    else 
      shell.log --tag ${_tag} --message "secrets json validated unsuccessfully"
      (( _error_count++ ))
    fi

  else
    #set exit code
    _exit_code=${exit_crit}
  fi

  # exit status
  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -sc 2>/dev/null)

  # exit
  ${cmd_echo} ${_exit_string}

  #return
  return ${_exit_code}
}