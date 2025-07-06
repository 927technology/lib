927.ops.start.jobserver() {
  # description
  # 

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/exits.v

  # argument variables
  local _json="{}"
  local _json_secrets="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _restart=${false}

  # local variables
  local _json_processes=$( ${cmd_osqueryi} "select pid from processes where name=='gearmand' and parent==1" --json )
  local _path_gearmand=/etc/mod_gearman
  local _tag=927.ops.start.jobserver

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -s | --secrets )
        shift
        _json_secrets="${1}"
      ;;
    esac
    shift
  done  

  # main
  if  [[ -d ${_path_gearmand} ]]; then
    shell.log --screen --message "path ${_path_gearmand} exists" --tag ${_tag} --remote-server ${LOG_SERVER}
>&2 test

    # create /etc/mod_gearman/module.conf
    if 927.ops.create.mod_gearman-module --json ${_json_secrets}; then
      shell.log --screen --message "gearman module.conf created successfully" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "gearman module.conf creation failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi













  # compare candidate to running configurations
  if 927.ops.config.compare; then
    shell.log --screen --message "configurations match" --tag ${_tag} --remote-server ${LOG_SERVER}
  else
    shell.log --screen --message "configurations do not match" --tag ${_tag} --remote-server ${LOG_SERVER}

    # create ${_path_927}${_path_naemon}/candidate/conf.d
    if [[ ! -d ${_path_927}${_path_naemon}/candidate/conf.d ]]; then
      shell.log --screen --message "creating ${_path_927}${_path_naemon}/candidate/conf.d" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_mkdir} --parents ${_path_927}${_path_naemon}/candidate/conf.d
    fi

    # parse configuration -> ${_path_927}${_path_naemon}/candidate/conf.d
    for naemon_configuration in $( ${cmd_echo} ${_naemon_configurations} | ${cmd_sed} 's/,/\n/g' ); do
      # zero out loop variables
      _json=

      shell.log --screen --message "parsing ${naemon_configuration}" --tag ${_tag} --remote-server ${LOG_SERVER}
      _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/configuration.json | ${cmd_jq} -c '.'${naemon_configuration} )
      927.ops.create.${naemon_configuration} --json "${_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/${naemon_configuration}
      [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    done

    # parse templates -> ${_path_927}${_path_naemon}/candidate/conf.d/templates
    for naemon_template in $( ${cmd_echo} ${_naemon_templates} | ${cmd_sed} 's/,/\n/g' ); do
      # zero out loop variables
      _json=
      _naemon_template_type=

      shell.log --screen --message "parsing template ${naemon_template}" --tag ${_tag} --remote-server ${LOG_SERVER}
      _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/configuration.json | ${cmd_jq} -c '.templates.'${naemon_template} )
      927.ops.create.${naemon_template} --json "${_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/templates/${naemon_template} --template
      [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    done

    # hosts/clouds
    shell.log --screen --message "hosts/clouds" --tag ${_tag} --remote-server ${LOG_SERVER}
    _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/infrastructure.json | ${cmd_jq} -c '.hosts.clouds' )
    927.ops.create.hosts --json "${_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/hosts/clouds -T
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 

    # hosts/clouds/tennants
    shell.log --screen --message "hosts/clouds/tennants" --tag ${_tag} --remote-server ${LOG_SERVER}
    for cloud_json in $( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/infrastructure.json | ${cmd_jq} -c '.hosts.clouds[]' ); do
      _tenancy_label=$( ${cmd_echo} ${cloud_json} | ${cmd_jq} -r '.ops[0].name.string')
      
      for tennant_json in $( ${cmd_echo} "${cloud_json}" | ${cmd_jq} -c '.tennants' ); do
        927.ops.create.hosts --json "${tennant_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/hosts/clouds/tennants --tenancy ${_tenancy_label}
        [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
      done
    done

    # validate naemon configuration
    if 927.ops.config.validate; then
      shell.log --screen --message "unlinking running config" --tag ${_tag} --remote-server ${LOG_SERVER}
      [[ -L ${_path_927}${_path_naemon}/running ]] && ${cmd_unlink} ${_path_927}${_path_naemon}/running

      shell.log --screen --message "linking running config" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_ln} --symbolic $( ${cmd_readlink} ${_path_927}${_path_naemon}/candidate ) ${_path_927}${_path_naemon}/running
    
      shell.log --screen --message "linking naemon conf.d" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_ln} --symbolic ${_path_927}${_path_naemon}/running/conf.d ${_path_naemon}/conf.d

      if [[ $( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" --json | ${cmd_jq} -c '. | length' ) -gt 0 ]]; then
        shell.log --screen --message "restarting naemon"
        _pid=$( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" --json | ${cmd_jq} -r '.[0].pid' )
        ${cmd_kill} -HUP ${_pid}
      fi
    fi
  fi






















    # create secrets path
    if [[ ! -f ~gearmand/secrets ]]; then
      if ${cmd_mkdir} --parents ~gearmand/secrets; then
        shell.log --screen --message "~/gearmand/secrets created" --tag ${_tag} --remote-server ${LOG_SERVER}
      else
        shell.log --screen --message "~/gearmand/secrets creation failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      fi
    fi

    # crate ~gearmand/secrets/module.pwd
    if [[ ! -f ~gearmand/secrets/module.pwd ]]; then
      ${cmd_touch} ~gearmand/secrets/module.pwd  || (( _error_count++ ))
      shell.log --screen --message "creating ~gearmand/secrets/module.pwd" --tag ${_tag} --remote-server ${LOG_SERVER}
    fi

    # set owner/group ~gearmand/secrets
    if ${cmd_chown} -R gearmand:gearmand ~gearmand/secrets; then
      shell.log --screen --message "set owner/group for ~gearmand/secrets successful" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "set owner/group for ~gearmand/secrets failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi

    # set mode ~gearmand/secrets
    ${cmd_chmod} 600 -R ~gearmand/secrets  || (( _error_count++ ))

    # write ~gearmand/secrets/module.pwd
    if [[ -f ~gearmand/secrets/module.pwd ]]; then
      if [[ $( ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "pass_service-account_jobserver" ).value' | to_sha256 ) == $( ${cmd_echo} ~gearmand/secrets/module.pwd | to_sha256 ) ]]; then
        shell.log --screen --message "candidate module password matches" --tag ${_tag} --remote-server ${LOG_SERVER}
        
      else
        shell.log --screen --message "candidate module password does not match" --tag ${_tag} --remote-server ${LOG_SERVER}
        ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "pass_service-account_jobserver" ).value' > ~gearmand/secrets/module.pwd
        _restart=${true}
      fi
    fi

  # start/restart gearmand
  if  [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) == 0 ]] ||
      [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) -gt 1 ]]; then
    
    # kill all
    for pid in $( ${cmd_echo} ${_json_processes} | ${cmd_jq} -r '.[]' ); do
      if ${cmd_kill} -s ${pid}; then
        shell.log --screen --message "stopping gearmand(${pid}) successful" --tag ${_tag} --remote-server ${LOG_SERVER}
      else
        shell.log --screen --message "stopping gearmand(${pid}) failed" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      fi
    done
    
    # start
    if ${cmd_su} gearmand --shell=/bin/sh --preserve-environment "--command=${cmd_gearmand} --daemon --log-file none --syslog $OPTIONS" >/dev/null 2>&1; then
      shell.log --screen --message "starting gearmand successful" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "starting gearmand failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi
  
  else
    # restart
    if ${cmd_kill} -HUP $( ${cmd_echo} ${_json_processes} | ${cmd_jq} -r '.[0].pid' ); then
      shell.log --screen --message "restarting gearmand successful" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "restarting gearmand failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi
  fi

  else
    shell.log --screen --message "path ${_path_gearmand} does not exists" --tag ${_tag} --remote-server ${LOG_SERVER}
    (( _error_count++ ))
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}