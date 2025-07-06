927.ops.start.web() {
  # description
  # 

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/exits.v

  # argument variables
  local _json_secrets="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json_processes=$( ${cmd_osqueryi} "select pid from processes where name=='httpd' and parent==1" --json )
  local _restart=${false}
  local _tag=927.ops.start.job

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -s | --secrets )
        shift
        _json_secrets="${1}"
      ;;
    esac
    shift
  done  

  # main
  # create ~apache/secrets
  if [[ ! -d ~apache/secrets ]]; then
    ${cmd_mkdir} -p ~apache/secrets  || (( _error_count++ ))
    shell.log --screen --message "creating ~apache/secrets" --tag ${_tag} --remote-server ${LOG_SERVER}
  fi

  # set mode ~apache/secrets
  if $( ${cmd_chmod} 700 ~apache/secrets ); then
    shell.log --screen --message "set mode for ~apache/secrets successful" --tag ${_tag} --remote-server ${LOG_SERVER}
  else
    shell.log --screen --message "set mode for ~apache/secrets failed" --tag ${_tag} --remote-server ${LOG_SERVER}
    (( _error_count++ ))
  fi

  for file in cert key; do
    # crate tls files
    if [[ ! -f ~apache/secrets/tls.${file} ]]; then
      ${cmd_touch} ~apache/secrets/tls.${file}  || (( _error_count++ ))
      shell.log --screen --message "creating ~apache/secrets/tls.${file}" --tag ${_tag} --remote-server ${LOG_SERVER}
    fi

    # write tls files
    if [[ -f ~apache/secrets/tls.${file} ]]; then
      if [[ $( ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "tls-'${file}'_naemon_web" ).value' | to_sha256 ) == $( ${cmd_echo} ~apache/secrets/tls.${file} | to_sha256 ) ]]; then
        shell.log --screen --message "candidate tls ${file} matches" --tag ${_tag} --remote-server ${LOG_SERVER}
        
      else
        shell.log --screen --message "candidate tls ${file} does not match" --tag ${_tag} --remote-server ${LOG_SERVER}
        ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "tls-'${file}'_naemon_web" ).value' > ~apache/secrets/tls.${file}
        _restart=${true}
      fi
    fi
  done

  # set owner/group ~apache/secrets
  if ${cmd_chown} -R apache:apache ~apache/secrets; then
    shell.log --screen --message "set owner/group for ~apache/secrets successful" --tag ${_tag} --remote-server ${LOG_SERVER}
  else
    shell.log --screen --message "set owner/group for ~apache/secrets failed" --tag ${_tag} --remote-server ${LOG_SERVER}
    (( _error_count++ ))
  fi

  # set mode ~apache/secrets/tls.cert
  ${cmd_chmod} 644 ~apache/secrets/tls.cert  || (( _error_count++ ))

  # set mode ~apache/secrets/tls.key
  ${cmd_chmod} 600 ~apache/secrets/tls.key  || (( _error_count++ ))

  # start/restart httpd
  if  [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) == 0 ]] ||
      [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) -gt 1 ]]; then
    
    # kill all
    for pid in $( ${cmd_echo} ${_json_processes} | ${cmd_jq} -r '.[]' ); do
      if ${cmd_kill} -s ${pid}; then
        shell.log --screen --message "stopping httpd(${pid}) successful" --tag ${_tag} --remote-server ${LOG_SERVER}
      else
        shell.log --screen --message "stopping httpd(${pid}) failed" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      fi
    done
    
    # start
    if ${cmd_httpd} -DBACKGROUND >/dev/null 2>&1; then
      shell.log --screen --message "starting httpd successful" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "starting httpd failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi
  
  else
    # restart
    if ${cmd_kill} -HUP $( ${cmd_echo} ${_json_processes} | ${cmd_jq} -r '.[0].pid' ); then
      shell.log --screen --message "restarting httpd successful" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "restarting httpd failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}