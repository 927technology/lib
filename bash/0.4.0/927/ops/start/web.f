927.ops.start.web () {

  # description
  # start the httpd service for the ops manager

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/nagios.v
  # 927/secretservice.l
  # shell.l
  # json/validate.f

  # because IFS sucks
  IFS=$'\n'  

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local _configuration_changes=0

  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  local _json_ps=
  local _pid_count=0
  local _tag=927.ops.start.web

  # parse command arguments
  # none

  # main

  # fresh json to write for event
  _json="{}"

  # make ~apache secrets path if missing
  # set path in json
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.path.name |=.+ "~apache/secrets"' )

  if [[ ! -d ~apache/secrets ]]; then
    # create path
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.path.exist |=.+ '${false} )
    
    ${cmd_mkdir} -p ~apache/secrets
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.path.success |=.+ '${true}   )
      shell.log --screen --message "~apache/secrets succssfully created"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.path.success |=.+ '${false}  )
      shell.log --screen --message "~apache/secrets failed creation"
    fi

    # set owner/group
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.owner.owner |=.+ "apache"' )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.owner.group |=.+ "apache"' )

    ${cmd_chown} apache:apache ~apache/secrets
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.owner.success |=.+ '${true}  )
      shell.log --screen --message "setting owner on ~apache/secrets successful"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.owner.success |=.+ '${false} )
      shell.log --screen --message "setting owner on ~apache/secrets failed"
    fi

    # set mode
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.mode.value |=.+ 700' )

    ${cmd_chmod} 700 ~apache/secrets
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.mode.success |=.+ '${true}  )
      shell.log --screen --message "setting mode ~apache/secrets successful"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.mode.success |=.+ '${false} )
      shell.log --screen --message "setting mode on ~apache/secrets failed"
    fi

  else
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.path.exist    |=.+ '${true}   )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.path.success  |=.+ null'      )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.chown.owner   |=.+ null'      )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.chown.group   |=.+ null'      )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.chown.success |=.+ null'      )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.mode.value    |=.+ null'      )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.chmod.success |=.+ null'      )
    
    shell.log --screen --message "~apache/secrets exists"

  fi

  # write log
  shell.log --tag ${_tag} --remote ${LOG_SERVER} --json "${_json}"
  
  # copy tls-cert
  # fresh json to write for event
  _json="{}"

  if [[ -f /opt/secrets/web/tls-cert/naemon ]]; then
    ${cmd_cp} /opt/secrets/web/tls-cert/naemon ~apache/secrets/tls.cert
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.success |=.+ '${true}  )
      shell.log --screen --message "tls-key added successfull"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.success |=.+ '${false} )
      shell.log --screen --message "tls-key failed to failed"
    fi

    ${cmd_chown} apache:apache ~apache/secrets/tls.cert
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.owner.success |=.+ '${true}  )
      shell.log --screen --message "setting owner on tls-cert successful"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.owner.success |=.+ '${false} )
      shell.log --screen --message "setting owner on tls-cert failed"
    fi

    ${cmd_chmod} 644 ~apache/secrets/tls.cert
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.mode.success |=.+ '${true}  )
      shell.log --screen --message "setting mode on tls-cert successfull"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.mode.success |=.+ '${false} )
      shell.log --screen --message "setting mode on tls-cert failed"
    fi

  else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.successful     |=.+ '${false}  )
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.owner.success  |=.+ null'      )
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.cert.mode.success   |=.+ null'      )
  
      shell.log --screen --message "missing secret /opt/secrets/web/tls-cert/naemon"
  fi

  # write log
  shell.log --tag ${_tag} --remote ${LOG_SERVER} --json "${_json}"
  
  # copy tls-key
  # fresh json to write for event
  _json="{}"

  if [[ -f /opt/secrets/web/tls-key/naemon ]]; then
    ${cmd_cp} /opt/secrets/web/tls-key/naemon ~apache/secrets/tls.key
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.success |=.+ '${true}  )
      shell.log --screen --message "tls-key added"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.success |=.+ '${false} )
      shell.log --screen --message "tls-key added"
    fi

    ${cmd_chown} apache:apache ~apache/secrets
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.owner |=.+ '${true}  )
      shell.log --screen --message "setting owner on tls-key successful"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.owner |=.+ '${false} )
      shell.log --screen --message "setting owner on tls-key failed"
    fi

    ${cmd_chmod} 600 ~apache/secrets/tls.key
    if [[ ${?} == ${exit_ok} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.mode |=.+ '${true}  )
      shell.log --screen --message "setting mode on tls-cert successful"
    else
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.mode |=.+ '${false} )
      shell.log --screen --message "setting mode on tls-cert failed"
    fi
  else
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.successful    |=.+ null'  )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.owner.success |=.+ null'  )
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.tls.key.mode.success  |=.+ null'  )
  
    shell.log --screen --message "missing secret /opt/secrets/web/tls-cert/naemon"
  fi
  
  # write log
  shell.log --tag ${_tag} --remote ${LOG_SERVER} --json "${_json}"
  

  # start httpd
  # fresh json to write for event
  _json="{}"

  # get running processes whose parent is init(1)
  _json_ps=$( ${cmd_osqueryi} --json "select * from processes where cmdline == '/usr/sbin/httpd -DBACKGROUND' and parent == 1" | ${cmd_jq} -c )
  
  # is process already running?
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.process['${_pid_count}'].cmdline |=.+ "'${cmd_httpd}' -DBACKGROUND"'  )

  if [[ $( ${cmd_echo} ${_json_ps} | ${cmd_jq} 'length' ) > 0 ]]; then

    # restart process(es) using HUP
    for pid in $( ${cmd_echo} ${_json_ps} | ${cmd_jq} -r '.[].pid' ); do
      ${cmd_kill} -HUP ${pid}

      if [[ ${?} == ${exit_ok} ]]; then
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.process['${_pid_count}'].restart |=.+ '${true}  )
      else
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.process['${_pid_count}'].restart |=.+ '${false} )
      fi

    done
  
  else
    #start new process
    ${cmd_httpd} -DBACKGROUND >/dev/null 2>&1

  fi

  shell.log --tag ${_tag} --remote ${LOG_SERVER} --json "${_json}"
}