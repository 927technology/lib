naemon.create.hosts() {
  # description
  # creates ops hosts stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # date/epoch.f
  # date/pretty.f
  # json/validate.f
  # json/timestamp.f

  # argument variables
  local _is_tenancy=${false}
  local _json=
  local _path=
  local _template=${false}
  local _tenancy=
  
  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # date variables
  local _json_timestamp=$( json.timestamp )

  # host variables
  local _2d_coords=
  local _3d_coords=
  local _active_checks_enabled=
  local _action_url=
  local _address=
  local _alias=
  local _check_command=
  local _check_freshness=
  local _check_period=
  local _check_interval=
  local _contact_groups=
  local _contacts=
  local _display_name=
  local _event_handler=
  local _event_handler_enabled=
  local _first_notification_delay=
  local _flap_detection_enabled=
  local _flap_detection_options=
  local _freshness_threshold=
  local _high_flap_threshold=
  local _host_name=
  local _hostgroups=
  local _iac_json="{}"
  local _icon_image=
  local _icon_image_alt=
  local _initial_state=
  local _low_flap_threshold=
  local _max_check_attempts=
  local _notes=
  local _notes_url=
  local _notification_interval=
  local _notification_options=
  local _notification_period=
  local _notifications_enabled=
  local _obsess_over_host=
  local _ops_json="{}"
  local _parents=
  local _passive_checks_enabled=
  local _process_perf_data=
  local _retain_nonstatus_information=
  local _retain_status_information=
  local _retry_interval=
  local _stalking_options=
  local _statusmap_image=
  local _vrml_image=
  local _use=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
      ;;
      -t | --template )
        _template=${true}
      ;;
      --tenancy )
        shift
        _tenancy=${1}
      ;;
      -T )
        _is_tenancy=${true}
      ;;
    esac
    shift
  done

  ## main
  if [[ ! -z ${_json} ]] && [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*
    
    for host in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select(.enable == true)' ); do 

      # default variable values
      _2d_coords=
      _3d_coords=
      _active_checks_enabled=
      _action_url=
      _address=
      _alias=
      _check_command=
      _check_freshness=
      _check_period=
      _check_interval=
      _contact_groups=
      _contacts=
      _display_name=
      _event_handler=
      _event_handler_enabled=
      _first_notification_delay=
      _flap_detection_enabled=
      _flap_detection_options=
      _freshness_threshold=
      _high_flap_threshold=
      _host_name=
      _hostgroups=
      _iac_json="{}"
      _icon_image=
      _icon_image_alt=
      _initial_state=
      _low_flap_threshold=
      _max_check_attempts=
      _notes=
      _notes_url=
      _notification_interval=
      _notification_options=
      _notification_period=
      _notifications_enabled=
      _obsess_over_host=
      _ops_json="{}"
      _parents=
      _passive_checks_enabled=
      _process_perf_data=
      _retain_nonstatus_information=
      _retain_status_information=
      _retry_interval=
      _stalking_options=
      _statusmap_image=
      _vrml_image=
      _use=


      _2d_coords=$(                       ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].icon.coordinates."2d" )            | if( .x >= 0 and .y >= 0 ) then [ .x, .y ] | join(", ") else "" end ' )
      
      _3_coords=$(                        ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].icon.coordinates."3d" )            | if( .x >= 0 and .y >= 0 and .z >= 0 ) then [ .x, .y, .z ] | join(", ") else "" end' )
      
      _active_checks_enabled=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.active )                     | if( . == null ) then "" else . end' )
      
      _action_url=$(                      ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].action_url )                       | if( . == null ) then "" else . end' )
      
      _address=$(                         ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].address )                          | if( . == null ) then "" else . end' )
      
      _alias=$(                           ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].name.display )                     | if( . == null ) then "" else . end' )
      
      _check_command=$(                   ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.command )                    | if( . == null ) then "" else . end' )
      
      #_check_freshness=$(                 ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.freshness.enable )           | if( . == null ) then "" else . end' )
      _check_freshness=$(                 ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( try( .ops[0].check.freshness.enable  ) != null ) then ( .ops[0].check.freshness.enable  |  if( . == true ) then '${true}' else '${false}' end ) else "" end' )

      _check_period=$(                    ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.period )                     | if( . == null ) then "" else . end' )
      
      _check_interval=$(                  ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.interval.value )             | if( . == null ) then "" else . end' )
      
      _contact_groups=$(                  ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].contact_groups[] )                 | select( .enable == true ).name' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )
      
      _contacts=$(                        ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].contacts[] )                       | select( .enable == true ).name' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )
      
      _display_name=$(                    ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].name.display )                     | if( . == null ) then "" else . end' )
      
      _event_handler_enabled=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].event_handler.enable )             | if( . == true ) then '${true}' else '${false}' end' )
      
      _event_handler=$(                   ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( 
                                                                                  try( .ops[0].event_handler.name ) 
                                                                                    and 
                                                                                  '${_event_handler_enabled}' == '${true}' 
                                                                                ) then ( .ops[0].event_handler.name       | 
                                                                                  if( . == null ) then 
                                                                                    "" 
                                                                                  else 
                                                                                    . 
                                                                                  end
                                                                                ) 
                                                                                else 
                                                                                  "" 
                                                                                end' ) 
      
      _file_name=$(                       ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].name.string )                      | if( . == null ) then "" else . end' ) 
      
      _flap_detection_enabled=$(          ${cmd_echo} ${host}  | ${cmd_jq} -r  ' try( .ops[0].flap_detection_enabled )          | if( . == true ) then '${true}' else '${false}' end' )
      
      _flap_detection_options=$(          ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].flap_detection.options )           | to_entries[] | select( .value == true ) | .key[0:1]' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )
      
      _high_flap_threshold=$(             ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( 
                                                                                  try( .ops[0].flap_detection.threshold.high ) 
                                                                                    and 
                                                                                  '$( [[ ! -z ${_flap_detection_enabled} ]] && echo ${_flap_detection_enabled} || echo ${false} )' 
                                                                                ) then ( .ops[0].flap_detection.threshold.high  | 
                                                                                  if( . == null ) then 
                                                                                    "" 
                                                                                  else 
                                                                                    . 
                                                                                  end
                                                                                ) 
                                                                                else 
                                                                                  "" 
                                                                                end' ) 
      
      _low_flap_threshold=$(              ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( 
                                                                                  try( .ops[0].flap_detection.threshold.low ) 
                                                                                    and  
                                                                                  '$( [[ ! -z ${_flap_detection_enabled} ]] && echo ${_flap_detection_enabled} || echo ${false} )' 
                                                                                ) then ( .ops[0].flap_detection.threshold.low | 
                                                                                  if( . == null ) then 
                                                                                    "" 
                                                                                  else 
                                                                                    . 
                                                                                  end
                                                                                ) 
                                                                                else 
                                                                                  "" 
                                                                                end' ) 
      
      #_freshness_threshold=$(             ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.freshness.threshold )  | if( . == null ) then "" else . end' )
      _freshness_threshold=$(             ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( try( .ops[0].check.freshness.threshold  ) != null ) then .ops[0].retain.status else "" end' )
      
      _host_name=$(                       ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].name.string )                | if( . == null ) then "" else . end' )
      
      _hostgroups=$(                      ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].hostgroups[] )               | select( .enable == true ).name' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )








      _iac_json=$(                        ${cmd_echo} ${_iac_json} | ${cmd_jq}    '.data[0].iac                           |=.+  '$( ${cmd_echo} ${host}  | ${cmd_jq} -c  'try.iac  | if(length > 0) then . else [] end' ) )
      _iac_json=$(                        ${cmd_echo} ${_iac_json} | ${cmd_jq} -c '.                                      |=.+ '"${_json_timestamp}" )







      _icon_image=$(                      ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].icon.file.image )            | if( . == null ) then "" else . end' )
      
      _icon_image_alt=$(                  ${cmd_echo} ${host}  | ${cmd_jq} -r  ' try( .ops[0].icon.file.alternate )       | if( . == null ) then "" else . end' )
      
      _initial_state=$(                   ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].initial_state )              | if( . == null ) then "" else . end' )
      _initial_state=$(                   ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( try( .ops[0].initial_state  ) != null ) then .ops[0].initial_state else "" end' )
      
      _max_check_attempts=$(              ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.max_attempts )         | if( . == null ) then "" else . end' )
      
      _notes=$(                           ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].notes.string )               | if( . == null ) then "" else . end' )
      
      _notes_url=$(                       ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].notes.url )                  | if( . == null ) then "" else . end' )
      
      _notifications_enabled=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].notification.enable )        | if( . == true ) then '${true}' else '${false}' end' )
      











      _ops_json=$(                        ${cmd_echo} ${_ops_json}  | ${cmd_jq} -c  '.data[0].ops                         |=.+  '$( ${cmd_echo} ${host}  | ${cmd_jq} -c  'try.ops | if(length > 0) then . else [] end' ) )
      _ops_json=$(                        ${cmd_echo} ${_ops_json}  | ${cmd_jq} -c  '.                                    |=.+ '"${_json_timestamp}" )









      
      _first_notification_delay=$(        ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( 
                                                                                  try( .ops[0].notification.first_delay ) 
                                                                                    and 
                                                                                  '$( [[ ! -z ${_notifications_enabled} ]] && echo ${_notifications_enabled} || echo ${false} )' 
                                                                                ) then ( .ops[0].notification.first_delay | 
                                                                                  if( . == null ) then 
                                                                                    "" 
                                                                                  else 
                                                                                    . 
                                                                                  end
                                                                                ) 
                                                                                else 
                                                                                  "" 
                                                                                end' ) 
      
      _notification_interval=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( 
                                                                                  try( .ops[0].notification.interval ) 
                                                                                    and 
                                                                                  '$( [[ ! -z ${_notifications_enabled} ]] && echo ${_notifications_enabled} || echo ${false} )' 
                                                                                ) then ( .ops[0].notification.interval    | 
                                                                                  if( . == null ) then 
                                                                                    "" 
                                                                                  else 
                                                                                    . 
                                                                                  end
                                                                                ) 
                                                                                else 
                                                                                  "" 
                                                                                end' ) 
      
      _notification_options=$(            ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].notification.optionsg )      | to_entries[] | select( .value == true ) | .key[0:1]' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )
      
      _notification_interval=$(           ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( 
                                                                                  try( .ops[0].notification.period ) 
                                                                                    and 
                                                                                  '$( [[ ! -z ${_notifications_enabled} ]] && echo ${_notifications_enabled} || echo ${false} )' 
                                                                                ) then ( 
                                                                                  .ops[0].notification.interval | 
                                                                                  if( . == null ) then 
                                                                                    "" 
                                                                                  else 
                                                                                    . 
                                                                                  end
                                                                                ) 
                                                                                else 
                                                                                  "" 
                                                                                end' ) 
      
      _obsess_over_host=$(                ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].obsess )                     | if( . == null ) then "" else . end' )
      
      _parents=$(                         ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].parents[] )                  | select( .enable == true ).name' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )
      
      _passive_checks_enabled=$(          ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.passive )              | if( . == true ) then '${true}' else '${false}' end' )
      
      _process_perf_data=$(               ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.perfdata )             | if( . == true ) then '${true}' else '${false}' end' )
      
      #_retain_nonstatus_information=$(    ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].retain.nonstatus )           | if( . == true ) then '${true}' else '${false}' end' )
      retain_nonstatus_information=$(     ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( try( .ops[0].retain.nonstatus  ) != null ) then ( .ops[0].retain.nonstatus  |  if( . == true ) then '${true}' else '${false}' end ) else "" end' )
      
      #_retain_status_information=$(       ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].retain.status )              | if( . == true ) then '${true}' else '${false}' end' )
      _retain_status_information=$(       ${cmd_echo} ${host}  | ${cmd_jq} -r  'if( try( .ops[0].retain.status  ) != null ) then ( .ops[0].retain.status  |  if( . == true ) then '${true}' else '${false}' end ) else "" end' )
      
      _retry_interval=$(                  ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].check.interval.retry )       | if( . == null ) then "" else . end' )
      
      _stalking_options=$(                ${cmd_echo} ${host}  | ${cmd_jq}     'try( .ops[0].stalking ) | to_entries[]    | select( .value == true ) | .key[0:1]' | ${cmd_jq} -sr '. | if( . | length < 1 ) then "" else join(", ") end' )
      
      _statusmap_image=$(                 ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].icon.file.statusmap )        | if( . == null ) then "" else . end' )
      
      _vrml_image=$(                      ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].icon.image.vrml )            | if( . == null ) then "" else . end' )

      _use=$(                             ${cmd_echo} ${host}  | ${cmd_jq} -r  'try( .ops[0].use )                        | if( . == null ) then "" else . end' )
    

      shell.log --screen --message "Writing Host: ${_path}/${_file_name}.cfg"
      ${cmd_cat} << EOF.host > ${_path}/${_file_name}.cfg
define host                        {
$( [[ ! -z ${_2d_coords} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" 2d_coords "${_2d_coords}" )
$( [[ ! -z ${_3d_coords} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" 3d_coords "${_3d_coords}" )
$( [[ ! -z ${_active_checks_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" active_checks_enabled "${_active_checks_enabled}" )
$( [[ ! -z ${_action_url} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" action_url "${_action_url}" )
$( [[ ! -z ${_address} ]]                       && ${cmd_printf} '%-1s %-32s %-50s' "" address "${_address}" )
$( [[ ! -z ${_alias} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" alias "${_alias}" )
$( [[ ! -z ${_check_command} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" check_command "${_check_command}" )
$( [[ ! -z ${_check_freshness} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" check_freshness "${_check_freshness}" )
$( [[ ! -z ${_check_period} ]]                  && ${cmd_printf} '%-1s %-32s %-50s' "" check_period "${_check_period}" )
$( [[ ! -z ${_check_interval} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" check_interval "${_check_interval}" )
$( [[ ! -z ${_contact_groups} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" contact_groups "${_contact_groups}" )
$( [[ ! -z ${_contacts} ]]                      && ${cmd_printf} '%-1s %-32s %-50s' "" contacts "${_contacts}" )
$( [[ ! -z ${_display_name} ]]                  && ${cmd_printf} '%-1s %-32s %-50s' "" display_name "${_display_name}" )
$( [[ ! -z ${_event_handler} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" event_handler "${_event_handler}" )
$( [[ ! -z ${_event_handler_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" event_handler_enabled "${_event_handler_enabled}" )
$( [[ ! -z ${_first_notification_delay} ]]      && ${cmd_printf} '%-1s %-32s %-50s' "" first_notification_delay "${_first_notification_delay}" )
$( [[ ! -z ${_flap_detection_enabled} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" flap_detection_enabled "${_flap_detection_enabled}" )
$( [[ ! -z ${_flap_detection_options} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" flap_detection_options "${_flap_detection_options}" )
$( [[ ! -z ${_freshness_threshold} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" freshness_threshold "${_freshness_threshold}" )
$( [[ ! -z ${_high_flap_threshold} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" high_flap_threshold "${_high_flap_threshold}" )
$( [[ ! -z ${_host_name} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" host_name "${_host_name}" )
$( [[ ! -z ${_hostgroups} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" hostgroups "${_hostgroups}" )
$( [[ ! -z ${_icon_image} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" icon_image"${_icon_image}" )
$( [[ ! -z ${_icon_image_alt} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" icon_image_alt"${_icon_image_alt}" )
$( [[ ! -z ${_initial_state} ]]                 && ${cmd_printf} '%-1s %-32s %-50s' "" initial_state "${_initial_state}" )
$( [[ ! -z ${_low_flap_threshold} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" low_flap_threshold "${low_flap_threshold}" )
$( [[ ! -z ${_max_check_attempts} ]]            && ${cmd_printf} '%-1s %-32s %-50s' "" max_check_attempts "${_max_check_attempts}" )
$( [[ ${_template} == ${true} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" name "${_host_name}" )
$( [[ ! -z ${_notes} ]]                         && ${cmd_printf} '%-1s %-32s %-50s' "" notes "${_notes}" )
$( [[ ! -z ${_notes_url} ]]                     && ${cmd_printf} '%-1s %-32s %-50s' "" notes_url "${_notes_url}" )
$( [[ ! -z ${_notification_interval} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" notification_interval "${_notification_interval}" )
$( [[ ! -z ${_notification_options} ]]          && ${cmd_printf} '%-1s %-32s %-50s' "" notification_options "${_notification_options}" )
$( [[ ! -z ${_notification_period} ]]           && ${cmd_printf} '%-1s %-32s %-50s' "" notification_period "${_notification_period}" )
$( [[ ! -z ${_notifications_enabled} ]]         && ${cmd_printf} '%-1s %-32s %-50s' "" notifications_enabled "${_notifications_enabled}" )
$( [[ ! -z ${_obsess_over_host} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" obsess_over_host "${_obsess_over_host}" )
$( [[ ! -z ${_parents} ]]                       && ${cmd_printf} '%-1s %-32s %-50s' "" parents "${_parents}" )
$( [[ ! -z ${_passive_checks_enabled} ]]        && ${cmd_printf} '%-1s %-32s %-50s' "" passive_checks_enabled "${_passive_checks_enabled}" )
$( [[ ! -z ${_process_perf_data} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" process_perf_data "${_process_perf_data}" )
$( [[ ${_template} == ${true} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" register "${false}" || ${cmd_printf} '%-1s %-32s %-50s' "" register "${true}" )
$( [[ ! -z ${_retain_nonstatus_information} ]]  && ${cmd_printf} '%-1s %-32s %-50s' "" retain_nonstatus_information "${_retain_nonstatus_information}" )
$( [[ ! -z ${_retain_status_information} ]]     && ${cmd_printf} '%-1s %-32s %-50s' "" retain_status_information "${_retain_status_information}" )
$( [[ ! -z ${_retry_interval} ]]                && ${cmd_printf} '%-1s %-32s %-50s' "" retry_interval "${_retry_interval}" )
$( [[ ! -z ${_stalking_options} ]]              && ${cmd_printf} '%-1s %-32s %-50s' "" stalking_options "${_stalking_options}" )
$( [[ ! -z ${_statusmap_image} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" statusmap_image "${_statusmap_image}" )
$( [[ ! -z ${_vrml_image} ]]                    && ${cmd_printf} '%-1s %-32s %-50s' "" vrml_image "${_vrml_image}" )
$( [[ ! -z ${_use} ]]                           && ${cmd_printf} '%-1s %-32s %-50s' "" use "${_use}" )

$( [[ ${_template} == ${false} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" _is_tenancy "${_is_tenancy}" )
$( [[ ${_template} == ${false} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" _ops  \'"${_ops_json}"\' )
$( [[ ${_template} == ${false} ]]               && ${cmd_printf} '%-1s %-32s %-50s' "" _iac  \'"${_iac_json}"\' )

$( [[ ${_template} == ${false} ]] && \
   [[ ${_is_tenancy} == ${false} ]]             && ${cmd_printf} '%-1s %-32s %-50s' "" _tenancy  "${_tenancy}" )
}
EOF.host

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      ${cmd_sed} -i '/^[[:space:]]*$/d' ${_path}/${_file_name}.cfg
    done 

    if [[ ${_error_count} > 0 ]]; then
      _exit_code=${exit_crit}
      _exit_strin=${false}

    else  
      _exit_code=${exit_ok}
      _exit_strin=${true}

    fi

    # exit
    ${cmd_echo} ${_exit_string}
    return ${_exit_code}
  fi
}