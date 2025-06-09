927.secretservice.get.bitwarden.tlskeys () {
  # description
  # retrieves bitwarden tls keys

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _json="{}"
  local _verbose=${false}
  
  # local variables
  local _token=${false}
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _tag=927.secretservice.get.bitwarden.tlskeys

  # parse command arguments
  # none

  # main
  # check bws access token is present as an environmental variable
  [[ ! -z ${BWS_ACCESS_TOKEN} ]] && _token=${true}

  # print arguments to syslog
  shell.log --tag ${_tag} --message "token:${_token} provider:bitwarden key_type:tls-key"

  if [[ ${_token} == ${true} ]]; then
    _json=$( ${cmd_bws} secret list | ${cmd_jq} '.[] | select(.key | startswith("tls-key"))' )

    # validate success
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log --tag ${_tag} --message "tls-key retrieved successfully"

    else 
      shell.log --tag ${_tag} --message "tls-key retrieved unsuccessfully"
      (( _error_count++ ))
    fi

    # validate json
    json.validate --json "${_json}"
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log --tag ${_tag} --message "tls-key json validated successfully"

    else 
      shell.log --tag ${_tag} --message "tls-key json validated unsuccessfully"
      (( _error_count++ ))
    fi

  else
    #set exit code
    _exit_code=${exit_crit}
  fi

  # exit status
  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -sc )

  # exit
  ${cmd_echo} ${_exit_string}

  #return
  return ${_exit_code}
}