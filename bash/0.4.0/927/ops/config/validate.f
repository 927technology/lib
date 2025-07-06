927.ops.config.validate() {
  # description
  # checks candidate configuration in naemon
  # note:  this only validates the config it does not load it.
  # there is a change
  # accepts 0 arguments
  # only returns exit code, no output
  
  # dependancies
  # hash/sum/sha256.v
  # shell/log.f
  # variables/bools.v
  # variables/cmd_<platform>.v
  # variables/exits.v

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  
  # variables
  local _path_naemon=/etc/naemon
  local _path_927=/etc/927
  local _tag=927.ops.config.validate

  # parse command arguments
  # none

  # main
  # link candidate to ${_path_naemon}/conf.d to validate
  if [[ -L ${_path_927}${_path_naemon}/candidate ]]; then
    # unlink running config
    if [[ -L ${_path_naemon}/conf.d ]]; then
      shell.log --message "unlinking running config" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_unlink} ${_path_naemon}/conf.d
    fi

    # link candidate to naemon working cofnig path
    shell.log --message "linking candidate candidate" --tag ${_tag} --remote-server ${LOG_SERVER}
    ${cmd_ln} --symbolic ${_path_927}${_path_naemon}/candidate/conf.d ${_path_naemon}/conf.d
    
    # get exit status from command validation in naemon
    shell.log --message "validating candidate config" --tag ${_tag} --remote-server ${LOG_SERVER}
    ${cmd_su} naemon --shell=/bin/sh --preserve-environment "--command=${cmd_naemon} --verify-config ${_path_naemon}/naemon.cfg" > ${_path_927}/var/log/naemon.log ${std_out} && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    # return configuration to running
    shell.log --message "unlinking candidate config" --tag ${_tag} --remote-server ${LOG_SERVER}
    ${cmd_unlink} ${_path_naemon}/conf.d
    
    if [[ -L  ${_path_927}${_path_naemon}/running ]]; then
      shell.log --message "linking running config" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_ln} -s ${_path_927}${_path_naemon}/running/conf.d ${_path_naemon}/conf.d
    fi

  else
    shell.log --message "no candidate config available" --tag ${_tag} --remote-server ${LOG_SERVER}
    _exit_code=${exit_crit}
  fi

  # exit
  return ${_exit_code}
}