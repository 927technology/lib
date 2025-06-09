927.ops.start.manager () {

  # description
  # 

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
  local _path_927=/etc/927
  local _path_confd=/etc/naemon/conf.d
  local _path_gearman=/etc/mod_gearman
  local _path_livestatus=/var/cache/naemon/live
  local _path_naemon=/etc/naemon
  local _tag=927.ops.start.manager

  # parse command arguments
  # none

  # main
  # create configuration path
  [[ ! -d ${_path_927} ]] && ${cmd_mkdir} -p ${_path_927}

  # configuration variables
  _json_configuration_candidate=$( ${cmd_curl} -s ${URL}/configuration.json | ${cmd_jq} -c )
  _json_configuration_candidate_hash=$( ${cmd_echo} ${_json_configuration_candidate} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
  _json_configuration_running=$( ${cmd_cat} ${_path_927}/configuration.json | ${cmd_jq} -c )
  _json_configuration_running_hash=$( ${cmd_echo} ${_json_configuration_running} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )

  _json_infrastructure_candidate=$( ${cmd_curl} -s ${URL}/infrastructure.json | ${cmd_jq} -c )
  _json_infrastructure_candidate_hash=$( ${cmd_echo} ${_json_infrastructure_candidate} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
  _json_infrastructure_running=$( ${cmd_cat} ${_path_927}/infrastructure.json | ${cmd_jq} -c )
  _json_infrastructure_running_hash=$( ${cmd_echo} ${_json_infrastructure_running} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )

  if [[ ${_json_configuration_candidate_hash} != ${_json_configuration_running_hash} ]]; then                                                                                              \

    ${cmd_echo} New Candidate Configuration Detected
    ${cmd_echo} --------------------------------------------------------------------


    # contacts
    shell.log --screen --message "contacts"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.contacts' )
    927.ops.create.contacts -j "${_json}" -p ${_path_confd}/contacts
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # contactgroups
    shell.log --screen --message "contact groups"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.contactgroups' )
    927.ops.create.contactgroups -j "${_json}" -p ${_path_confd}/contactgroups
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # commands
    shell.log --screen --message "commands"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.commands' )
    927.ops.create.commands -j "${_json}" -p ${_path_confd}/commands
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # hostgroups
    shell.log --screen --message "hostgroups"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.hostgroups' )
    927.ops.create.hostgroups -j "${_json}" -p ${_path_confd}/hostgroups
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # services
    shell.log --screen --message "services"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.services' )
    927.ops.create.services -j "${_json}" -p ${_path_confd}/services
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # # servicegroups
    # shell.log --screen --message "servicegroups"
    # _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.servicegroups' )
    # 927.ops.create.servicegroups -j "${_json}" -p ${_path_confd}/servicegroups
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 


    # # servicedependencies
    # shell.log --screen --message "servicedependencies"
    # _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.servicedependencies' )
    # 927.ops.create.servicedependencies -j "${_json}" -p ${_path_confd}/servicedependencies
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 


    # # serviceescalations
    # shell.log --screen --message "serviceescalations"
    # _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.serviceescalations' )
    # 927.ops.create.servicedependencies -j "${_json}" -p ${_path_confd}/serviceescalations
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 


    # templates/contacts
    shell.log --screen --message "templates/contacts"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.contacts' )
    927.ops.create.contacts -j "${_json}" -p ${_path_confd}/templates/contacts -t
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # templates/hosts
    shell.log --screen --message "templates/hosts"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.hosts' )
    927.ops.create.hosts -j "${_json}" -p ${_path_confd}/templates/hosts -t
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # templates/hostgroups
    shell.log --screen --message "templates/hostgroups"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.hostgroups' )
    927.ops.create.hostgroups -j "${_json}" -p ${_path_confd}/templates/hostgroups -t
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # templates/routers
    shell.log --screen --message "templates/routers"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.routers' )
    927.ops.create.hosts -j "${_json}" -p ${_path_confd}/templates/routers -t
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo}


    # templates/servers
    shell.log --screen --message "templates/servers"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.templates.servers' )
    927.ops.create.hosts -j "${_json}" -p ${_path_confd}/templates/servers -t
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo}


    # timeperiods
    shell.log --screen --message "timeperiods"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.timeperiods' )
    927.ops.create.timeperiods -j "${_json}" -p ${_path_confd}/timeperiods
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 


    # output json to file
    ${cmd_echo} "${_json_configuration_candidate}" > ${_path_927}/configuration.json

    # increment changes
    (( _configuration_changes++ ))

  else
    shell.log --screen --message "New Candidate Configuration Not Detected"
    ${cmd_echo} --------------------------------------------------------------------
  fi

  ${cmd_echo} ====================================================================
  ${cmd_echo}
  ${cmd_echo}


  # write infrastructure to file
  if [[ $( 927.ops.config.new -j ${_json_infrastructure_running} -jc ${_json_infrastructure_candidate} ) != ${exit_ok} ]] && \
    [[ ${_json_infrastructure_candidate_validate} == ${true} ]]; then
    shell.log --screen --message "New Candidate Infrastructure Detected"
    ${cmd_echo} --------------------------------------------------------------------


    

    # hosts/clouds
    shell.log --screen --message "hosts/clouds"
    _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.clouds' )
    927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/clouds -T
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    _json=
    ${cmd_echo} 

    # hosts/clouds/tennants
    shell.log --screen --message "hosts/clouds/tennants"
    for cloud_json in $( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.clouds[]' ); do
      _tenancy_label=$( ${cmd_echo} ${cloud_json} | ${cmd_jq} -r '.ops[0].name.string')
      
      for tennant_json in $( ${cmd_echo} "${cloud_json}" | ${cmd_jq} -c '.tennants' ); do


        927.ops.create.hosts -j "${tennant_json}" -p ${_path_confd}/hosts/clouds/tennants --tenancy ${_tenancy_label}
        [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
      done
    done
    ${cmd_echo} 


    # # hosts/compartments
    # shell.log --screen --message "hosts/compartments"
    # _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.compartments' )
    # 927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/compartments
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 

    # # hosts/printers
    # shell.log --screen --message "hosts/printers"
    # _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.printers' )
    # 927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/printers
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 

    # # hosts/routers
    # shell.log --screen --message "hosts/routers"
    # _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.routers' )
    # 927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/routers
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 

    # # hosts/servers
    # shell.log --screen --message "hosts/servers"
    # _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.servers' )
    # 927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/servers
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 

    # # hosts/switches
    # shell.log --screen --message "hosts/switches"
    # _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.switches' )
    # 927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/switches
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 

    # # hosts/wireless
    # shell.log --screen --message "hosts/wireless"
    # _json=$( ${cmd_echo} "${_json_infrastructure_candidate}" | ${cmd_jq} -c '.hosts.wiereless' )
    # 927.ops.create.hosts -j "${_json}" -p ${_path_confd}/hosts/wireless
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 


    # services
    shell.log --screen --message "services"
    _json=$( ${cmd_echo} "${_json_configuration_candidate}" | ${cmd_jq} -c '.services' )
    #echo $_json | jq
    927.ops.create.services -j "${_json}" -p ${_path_confd}/services
    # [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 
    # _json=
    # ${cmd_echo} 


    # output json to file
    ${cmd_echo} "${_json_infrastructure_candidate}" > ${_path_927}/infrastructure.json

    # increment changes
    (( _configuration_changes++ ))

  else
    shell.log --screen --message "New Candidate Infrastructure Not Detected"
    ${cmd_echo} --------------------------------------------------------------------

  fi

  ${cmd_echo} ====================================================================
  ${cmd_echo}
  ${cmd_echo}


  if [[ ${_configuration_changes} > 0 ]]; then
    shell.log --screen --message "Validating Configuration"

    927.ops.validate -p ${_path_naemon} 1> /dev/null 2> /dev/null

    if [[ ${?} == ${exit_ok} ]]; then
      shell.log --screen --message "Validation Successfull"

      927.ops.restart --role manager

    else
      shell.log --screen --message "Validation Unsuccessfull"

    fi

  else
    shell.log --screen --message "No New Configuration Detected"

  fi
}
