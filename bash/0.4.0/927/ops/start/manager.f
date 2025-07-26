927.ops.start.manager () {
  # description
  # 

  # dependancies
  # 927/secretservice.l
  # json/validate.f 
  # shell.l
  # variables.l

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _count_role_secrets=0
  local _json_secrets=
  local _json_role_secrets=
  local _naemon_command="${cmd_naemon} --daemon /etc/naemon/naemon.cfg"
  local _naemon_configurations=contacts,contactgroups,commands,hostgroups,services,timeperiods
  local _naemon_infrastructures=hosts/clouds,hosts/clouds/tenants
  local _naemon_templates=contacts,hosts,hostgroups,routers,servers,services
  local _naemon_template_type=
  local _path_naemon=/etc/naemon
  local _path_927=/etc/927
  local _tag=927.ops.start.manager

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -g | --group )
        shift
        _group="${1}"
      ;;

    esac
    shift
  done  

  # main
  # delete /etc/naemon/conf.d if is directory. 972 ops uses a simlink 
  if  [[ -d ${_path_naemon}/conf.d ]] &&
      [[ ! -L ${_path_naemon}/conf.d ]]; then
    if ${cmd_rm} -rf ${_path_naemon}/conf.d; then
      shell.log --screen --message "DELETE: ${_path_naemon}/conf.d SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "DELETE: ${_path_naemon}/conf.d FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
    fi
  fi

  # compare candidate to running configurations
  if 927.ops.config.compare; then
    shell.log --screen --message "VALIDATE: configurations SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
  else
    shell.log --screen --message "VALIDATE: configurations FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}

    # create ${_path_927}${_path_naemon}/candidate/conf.d
    shell.create.directory --directory ${_path_927}${_path_naemon}/candidate/conf.d --group naemon --mode 770 --owner naemon 
    # set owner:group and mode for ${_path_927}
    shell.create.directory --directory ${_path_927} --group naemon --mode 770 --owner naemon --recursive
 
    # parse configuration -> ${_path_927}${_path_naemon}/candidate/conf.d
    for naemon_configuration in $( ${cmd_echo} ${_naemon_configurations} | ${cmd_sed} 's/,/\n/g' ); do
      # zero out loop variables
      _json=

      shell.log --screen --message "parsing ${naemon_configuration}" --tag ${_tag} --remote-server ${LOG_SERVER}
      _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/configuration.json | ${cmd_jq} -c '.'${naemon_configuration} )
      927.ops.create.${naemon_configuration} --json "${_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/${naemon_configuration} || (( _error_count++ )) 
    done

    # parse templates -> ${_path_927}${_path_naemon}/candidate/conf.d/templates
    for naemon_template in $( ${cmd_echo} ${_naemon_templates} | ${cmd_sed} 's/,/\n/g' ); do
      # zero out loop variables
      _json=
      _naemon_template_type=

      shell.log --screen --message "parsing template ${naemon_template}" --tag ${_tag} --remote-server ${LOG_SERVER}
      _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/configuration.json | ${cmd_jq} -c '.templates.'${naemon_template} )
      927.ops.create.${naemon_template} --json "${_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/templates/${naemon_template} --template || (( _error_count++ )) 
    done

    # hosts/clouds
    shell.log --screen --message "hosts/clouds" --tag ${_tag} --remote-server ${LOG_SERVER}
    _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/infrastructure.json | ${cmd_jq} -c '.hosts.clouds' )
    927.ops.create.hosts --json "${_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/hosts/clouds -T || (( _error_count++ )) 

    # hosts/clouds/tennants
    shell.log --screen --message "hosts/clouds/tennants" --tag ${_tag} --remote-server ${LOG_SERVER}
    for cloud_json in $( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/infrastructure.json | ${cmd_jq} -c '.hosts.clouds[]' ); do
      _tenancy_label=$( ${cmd_echo} ${cloud_json} | ${cmd_jq} -r '.ops[0].name.string')
      
      for tennant_json in $( ${cmd_echo} "${cloud_json}" | ${cmd_jq} -c '.tennants' ); do
        927.ops.create.hosts --json "${tennant_json}" --path ${_path_927}${_path_naemon}/candidate/conf.d/hosts/clouds/tennants --tenancy ${_tenancy_label} || (( _error_count++ )) 
      done
    done

    # validate naemon configuration
    if 927.ops.config.validate; then
      if [[ -L ${_path_927}${_path_naemon}/running ]] && ${cmd_unlink} ${_path_927}${_path_naemon}/running; then
        shell.log --screen --message "UNLINKING: ${_path_927}${_path_naemon}/running SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
      else  
        shell.log --screen --message "UNLINKING: ${_path_927}${_path_naemon}/running FAILURE" --tag ${_tag} --remote-server ${LOG_SERVER}
      fi

      shell.log --screen --message "linking running config" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_ln} --symbolic $( ${cmd_readlink} ${_path_927}${_path_naemon}/candidate ) ${_path_927}${_path_naemon}/running
    
      if ${cmd_ln} --symbolic ${_path_927}${_path_naemon}/running/conf.d ${_path_naemon}/conf.d; then
        shell.log --screen --message "LINKING ${_path_927}${_path_naemon}/running/conf.d -> /etc/naemon/conf.d SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
      else
        shell.log --screen --message "LINKING ${_path_927}${_path_naemon}/running/conf.d -> /etc/naemon/conf.d FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
      fi 

      # restart naemon
      shell.process.restart --process naemon

      # if [[ $( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" --json | ${cmd_jq} -c '. | length' ) -gt 0 ]]; then
      #   shell.log --screen --message "RESTARTING naemon"
      #   _pid=$( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" --json | ${cmd_jq} -r '.[0].pid' )
      #   ${cmd_kill} -HUP ${_pid}
      # fi
    fi
  fi

  if [[ $( ${cmd_osqueryi} "select pid from processes where name == 'naemon' and parent == 1" --json | ${cmd_jq} -c '. | length' ) == 0 ]]; then
    if [[ ! -L ${_path_naemon}/conf.d ]] && ${cmd_ln} --symbolic ${_path_927}${_path_naemon}/running/conf.d ${_path_naemon}/conf.d; then
      shell.log --screen --message "LINKING: ${_path_927}${_path_naemon}/running/conf.d ${_path_naemon}/conf.d SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "LINKING: ${_path_927}${_path_naemon}/running/conf.d ${_path_naemon}/conf.d FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
    fi
    
    # shell.log --screen --message "starting naemon" --tag ${_tag} --remote-server ${LOG_SERVER}
    shell.process.start --command "${_naemon_command}"- -preserve-environment --user naemon || (( _error_count++ ))
    # ${cmd_su} naemon --shell=/bin/sh --preserve-environment "--command=${cmd_naemon} --daemon /etc/naemon/naemon.cfg"
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}