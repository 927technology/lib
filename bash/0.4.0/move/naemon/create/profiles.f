move.naemon.create.profiles() {
  # local variables
  local _file_hash=
  local _restart_naemon_count=0
  local _path_naemon=/etc/naemon
  local _profile_count=0
  local _profile_path=/usr/local/etc/move

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local profile=
  local folder=

  # parse arguments
  # none

  # main
  # create profiles/hostgrops folders
  if [[ ! -d ${_path_naemon}/conf.d/profiles/.delete ]]; then
    shell.log "${FUNCNAME}(${_profile}) - [CREATING] ${_path_naemon}/conf.d/profiles/.delete"
    ${cmd_mkdir} --parents ${_path_naemon}/conf.d/profiles/.delete
  fi

  if [[ ! -d ${_path_naemon}/conf.d/hostgroups/profiles/.delete ]]; then
    shell.log "${FUNCNAME}(${_profile}) - [CREATING] ${_path_naemon}/conf.d/hostgroups/profiles/.delete"
    ${cmd_mkdir} --parents ${_path_naemon}/conf.d/hostgroups/profiles/.delete
  fi

  # move profiles to .delete
  shell.log "${FUNCNAME}(${_profile}) - [MOVING] ${_path_naemon}/conf.d/profiles/*.cfg to ${_path_naemon}/conf.d/profiles/.delete"
  ${cmd_mv} ${_path_naemon}/conf.d/profiles/*.cfg ${_path_naemon}/conf.d/profiles/.delete/ > /dev/null 2>&1

  # move hostgroups/profiles to .delete
  shell.log "${FUNCNAME}(${_profile}) - [MOVING] ${_path_naemon}/conf.d/hostgroups/profiles/*.cfg to ${_path_naemon}/conf.d/hostgroups/profiles/.delete"
  ${cmd_mv} ${_path_naemon}/conf.d/hostgroups/profiles/*.cfg ${_path_naemon}/conf.d/hostgroups/profiles/.delete/ > /dev/null 2>&1

  for profile in $( move.list.profiles --output name ); do
    # zero loop variables
    _file_hash= 

    # check if profile is new/updated or existing
    if    [[ -f ${_path_naemon}/conf.d/profiles/.delete/${profile}.cfg ]]; then
      _file_hash=$( ${cmd_sha256sum} ${_path_naemon}/conf.d/profiles/.delete/${profile}.cfg | ${cmd_awk} '{print $1}' )    
      # echo $_file_hash
    else
      (( _restart_naemon_count++ ))

    fi

    # create profile host defination
    ${cmd_cat} << EOF.profile > ${_path_naemon}/conf.d/profiles/${profile}.cfg

define host                        {
  alias                            profile.${profile}                            
  event_handler_enabled            0                                                 
  flap_detection_enabled           0                                                 
  host_name                        profile.${profile}                                    
  hostgroups                       move.profiles, move.profiles.${profile}                     
  notifications_enabled            0                                                 
  passive_checks_enabled           0                                                 
  process_perf_data                0                                                 
  register                         1                                                 
  use                              generic-vsphere   
  _profile                         ${profile}
  _search                          ${profile}
  _type                            folder                                
}
EOF.profile

    # output success/failure
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log "${FUNCNAME} - [SUCCESS] Profile: ${profile}"
    
      if  [[ ${_file_hash} != $( ${cmd_sha256sum} ${_path_naemon}/conf.d/profiles/${profile}.cfg | ${cmd_awk} '{print $1}' ) ]]; then
        (( _restart_naemon_count++ ))

      fi
    else
      shell.log "${FUNCNAME} - [FAILURE] Profile: ${profile}"
      (( _error_count++ ))

    fi

    # zero loop variable
    _file_hash=

    # check if hostgroup is new/updated or existing
    if    [[ -f ${_path_naemon}/conf.d/hostgroups/profiles/.delete/${profile}.cfg ]]; then
      _file_hash=$( ${cmd_sha256sum} ${_path_naemon}/conf.d/hostgroups/profiles/.delete/${profile}.cfg | ${cmd_awk} '{print $1}' )    

    else
      (( _restart_naemon_count++ ))

    fi

    # create profile hostgroup
    ${cmd_cat} << EOF.hostgroup > ${_path_naemon}/conf.d/hostgroups/profiles/${profile}.cfg
define hostgroup           {
  alias                    Move Profiles - ${profile}
  hostgroup_name           move.profiles.${profile}
}
EOF.hostgroup

    # output success/failure
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log "${FUNCNAME} - [SUCCESS] Host Group: move.profiles.${profile}"
      if  [[ ${_file_hash} != $( ${cmd_sha256sum} ${_path_naemon}/conf.d/hostgroups/profiles/${profile}.cfg | ${cmd_awk} '{print $1}' ) ]]; then
        (( _restart_naemon_count++ ))
      
      fi
    else
      shell.log "${FUNCNAME} - [FAILURE] Host Group: move.profiles.${profile}"
      (( _error_count++ ))

    fi

    (( _profile_count++ ))
  done


  if [[ ${_error_count} != 0 ]]; then
    shell.log "${FUNCNAME} - [FAILURE] Errors Occured, Naemon will not be restarted"
    _exit_code=${exit_crit}

  else
    # restart naemon process
    [[ ${_restart_naemon_count} > 0 ]] && naemon.restart
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

  fi

  # cleanup ${_path_naemon}/conf.d/profiles/.delete
  shell.log "${FUNCNAME}(${_profile}) - [CLEANUP] ${_path_naemon}/conf.d/profiles/.delete"
  ${cmd_rm} --recursive --force ${_path_naemon}/conf.d/profiles/.delete

  # cleanup ${_path_naemon}/conf.d/hostgroups/profiles/.delete
  shell.log "${FUNCNAME}(${_profile}) - [CLEANUP] ${_path_naemon}/conf.d/hostgroups/profiles/.delete"
  ${cmd_rm} --recursive --force ${_path_naemon}/conf.d/hostgroups/profiles/.delete

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} "(${_profile_count}) Profiles Parsed"
  return ${_exit_code}
}