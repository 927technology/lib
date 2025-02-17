927.tor.create.torrc () {
  # description
  # creates torrc configuration
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated torrc write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _json=
  local _path=


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # commands variables
  local _address=
  local _control_port=
  local _daemon=
  local _data_dir=
  local _directories_json

  local _families_json=
  local _families_count=

  local _log_debug_enable=
  local _log_debug_file=
  local _log_debug_output=

  local _log_notices_enable=
  local _log_notices_file=
  local _log_notices_output=
  
  local _nickname=

  local _outboundbindaddress=

  local _relaybandwithburst=
  local _relaybandwithrate=
  local _nickname=

  local _outboundbindaddress=

  local _relaybandwithburst=
  local _relaybandwithrate=

  local _relay_bridge_enable=
  local _relay_bridge_descriptor=

  local _relay_exitpolicies_json=
  local _relay_exitpolicies_count=
  local _relay_exitpolicy_ip=
  local _relay_exitpolicy_port_start=
  local _relay_exitpolicy_port_stop=
  local _relay_exitpolicy_rule=
  local _relay_exitpolicy_string=
  
  local _relay_orport_enable=
  local _relay_orport_address=
  local _relay_orport_advertise=
  local _relay_orport_listen=

  local _socks_accept_enable=
  local _socks_accept_prefix=
  local _socks_accept_subnet=

  local _socks_interface_primary_address=
  local _socks_interface_primary_port=

  local _socks_reject_enable=
  local _socks_reject_prefix=
  local _socks_reject_subnet=

  local _socks_secondary_address=
  local _socks_secondary_port=


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

    esac
    shift
  done

  ## main
  if [[ ! -z ${_json} ]]; then
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path}

    _address=$(                         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.address                    ) != null       ) then .relay.address                     else "" end' )
    _control_port=$(                    ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .control_port                     ) != null       ) then .control_port                      else "" end' )
    _daemon=$(                          ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .daemon                           ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _data_dir=$(                        ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .data_dir                         ) != null       ) then .data_dir                          else "/var/lib/tor"   end' )
    _directories_json=$(                ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .directories                      ) != null       ) then .directories                       else "[]"             end' | ${cmd_jq} -c '.[]' )
    
    _families_json=$(                   ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.families                   ) != null       ) then .relay.families                    else "[]"             end' | ${cmd_jq} -c '.[] | select(.enable == true)' )
    _families_count=$(                  ${cmd_echo} ${_families_json} | ${cmd_jq} -c '.[]')
    

    _log_debug_enable=$(                ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .log.debug.enable                 ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _log_debug_file=$(                  ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .log.debug.file                   ) != null       ) then .log.debug.file                    else ""               end' )
    _log_debug_output=$(                ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .log.debug.output                 ) != null       ) then .log.debug.output                  else ""               end' )
    
    _log_notices_enable=$(              ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .log.notices.enable               ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _log_notices_file=$(                ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .log.notices.file                 ) != null       ) then .log.notices.file                  else ""               end' )
    _log_notices_output=$(              ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .log.notices.output               ) != null       ) then .log.notices.output                else ""               end' )

    _nickname=$(                        ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.nickname                   ) != null       ) then .relay.nickname                    else ""               end' )

    _outboundbindaddress=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.outboundbindaddress        ) != null       ) then .relay.outboundbindaddress         else ""               end' )

    _relaybandwithburst=$(              ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.bandwith.burst             ) != null       ) then .relay.bandwith.burst              else ""               end' )
    _relaybandwithrate=$(               ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.bandwith.rate              ) != null       ) then .relay.bandwith.rate               else ""               end' )

    _relay_accounting_enable=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.accounting.enable          ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _relay_accounting_amount=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.accounting.amount          ) != null       ) then .relay.accounting.amount           else ""               end' )
    _relay_accounting_day=$(            ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.accounting.day             ) != null       ) then .relay.accounting.day              else ""               end' )
    _relay_accounting_period=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.accounting.period          ) != null       ) then .relay.accounting.period           else ""               end' )
    _relay_accounting_time=$(           ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.accounting.time            ) != null       ) then .relay.accounting.period           else ""               end' )

    _relay_bridge_enable=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.bridge.enable              ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _relay_bridge_descriptor=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.bridge.discriptor          ) == '${true}'  ) then '${true}'                          else '${false}'       end' )

    _relay_contact_enable=$(            ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.contact.enable             ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _relay_contact_email=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.contact.email              ) != null       ) then .relay.contact.email               else ""               end' )
    _relay_contact_gpg=$(               ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.contact.gpg                ) != null       ) then .relay.contact.gpg                 else ""               end' )

    _relay_enable=$(                    ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.enable                     ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    
    _relay_exitpolicies_json=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.exitpolicies               ) != null       ) then .relay.exitpolicies                else "[]"             end' | ${cmd_jq} -c '.[] | select(.enable == true)' )
    _relay_exitpolicies_count=$(        ${cmd_echo} ${_relay_exitpolicies_json}  | ${cmd_jq} -c '.[]')

    _relay_dirport_enable=$(            ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.dirport.enable             ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _relay_dirport_address=$(           ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.dirport.address            ) != null       ) then .relay.orport.address              else ""               end' )
    _relay_dirport_advertise=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.dirport.advertise          ) != null       ) then .relay.orport.advertise            else ""               end' )
    _relay_dirport_listen=$(            ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.dirport.listen             ) != null       ) then .relay.orport.listen               else ""               end' )

    _relay_orport_enable=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.orport.enable              ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _relay_orport_address=$(            ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.orport.address             ) != null       ) then .relay.orport.address              else ""               end' )
    _relay_orport_advertise=$(          ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.orport.advertise           ) != null       ) then .relay.orport.advertise            else ""               end' )
    _relay_orport_listen=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .relay.orport.listen              ) != null       ) then .relay.orport.listen               else ""               end' )

    _socks_interface_primary_address=$( ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.interface.primary.address  ) != null       ) then .socks.interface.primary.address   else ""               end' )
    _socks_interface_primary_port=$(    ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.interface.primary.port     ) != null       ) then .socks.interface.primary.port      else ""               end' )
    
    _socks_accept_enable=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.accept.enable              ) != '${true}'  ) then '${true}'                          else '${false}'       end' )
    _socks_accept_prefix=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.accept.prefix              ) != null       ) then .socks.accept.prefix               else ""               end' )
    _socks_accept_subnet=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.accept.subnet              ) != null       ) then .socks.accept.subnet               else ""               end' )

    _socks_reject_enable=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.reject.enable              ) == '${true}'  ) then '${true}'                          else '${false}'       end' )
    _socks_reject_prefix=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.reject.prefix              ) != null       ) then .socks.reject.prefix               else ""               end' )
    _socks_reject_subnet=$(             ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.reject.subnet              ) != null       ) then .socks.reject.subnet               else ""               end' )

    _socks_secondary_address=$(         ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.interface.secondary.address) != null       ) then .socks.interface.secondary.address else ""               end' )
    _socks_secondary_port=$(            ${cmd_echo} ${_json}          | ${cmd_jq} -r  'if( try( .socks.interface.secondary.port   ) != null       ) then .socks.interfacesecondary.port     else ""               end' )

    ${cmd_echo} Writing Config: ${_path}/torrc
    ${cmd_cat} << EOF.torrc > ${_path}/torrc
# control port
$(  if [[ ! -z ${_control_port} ]]; then                                                            \
       ${cmd_printf} "ControlPort ${_control_port}";                                                \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# data dir
DataDirectory ${_data_dir}

# primary interface and port
$(  if [[ ! -z ${_socks_interface_primary_port} ]] &&                                               \
       [[ ${_socks_interface_primary_address} == "0.0.0.0" ]]; then                                 \
       ${cmd_printf} "SocksPort ${_socks_interface_primary_port}";                                  \
    elif [[ ! -z ${_socks_interface_primary_port} ]] &&                                             \
       [[ ${_socks_interface_primary_address} != "0.0.0.0" ]] &&                                    \
       [[ ! -z ${_socks_interface_primary_address} ]]; then                                         \
       ${cmd_printf} "SocksPort ${_socks_interface_primary_address}:${_socks_interface_primary_port}"; \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# secondary interface and port
$(  if [[ ! -z ${_socks_interface_secondary_port} ]] &&                                             \
       [[ ! -z ${_socks_interface_secondary_address} ]]; then                                       \
       ${cmd_printf} "SocksPort ${_socks_interface_secondary_address}:${_socks_interface_secondary_port}"; \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# accept subnet
$(  if [[ ${_socks_accept_enable} ]] &&                                                             \
       [[ ! -z ${_socks_accept_subnet} ]] &&                                                        \
       [[ ! -z ${_socks_accept_prefix} ]]; then                                                     \
       ${cmd_printf} "SocksPolicy accept  ${_socks_accept_subnet}/${_socks_accept_prefix}";         \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# reject subnet
$(  if [[ ${_socks_reject_enable} == ${true} ]] &&                                                  \
       [[ ! -z ${_socks_reject_subnet} ]] &&                                                        \
       [[ ! -z ${_socks_reject_prefix} ]]; then                                                     \
       ${cmd_printf} "SocksPolicy reject ${_socks_reject_subnet}/${_socks_reject_prefix}";          \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# log debug file
$(  if [[ ${_log_debug_enable} ]] &&                                                                \
       [[ ! -z ${_log_debug_file} ]]; then                                                          \
       ${cmd_printf} "Log debug file ${_log_debug_file}";                                           \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# log debug output
$(  if [[ ${_log_debug_enable} ]] &&                                                                \
       [[ ! -z ${_log_debug_output} ]]; then                                                        \
       ${cmd_printf} "Log debug ${_log_debug_output}";                                              \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# log notices file
$(  if [[ ${_log_notices_enable} ]] &&                                                              \
       [[ ! -z ${_log_notices_file} ]]; then                                                        \
       ${cmd_printf} "Log notice file ${_log_notices_file}";                                       \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# log notices output
$(  if [[ ${_log_notices_enable} ]] &&                                                              \
       [[ ! -z ${_log_notices_output} ]]; then                                                      \
       ${cmd_printf} "Log notice ${_log_notices_output}";                                          \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

RunAsDaemon ${_daemon}

# services
$(  for directory in $( ${cmd_echo} ${_directories_json} ); do                                      \
      _directory_key=$( ${cmd_echo} ${directory} | ${cmd_jq} '.key' );                              \
      _directory_name=$( ${cmd_echo} ${directory} | ${cmd_jq} -r '.name' );                         \
      _directory_services_json=$( ${cmd_echo} ${directory} | ${cmd_jq} -c '.services[]' );          \
      ${cmd_printf} "HiddenServiceDir /var/lib/tor/${_directory_name}/\n";                          \
      
      for service in $( ${cmd_echo} ${_directory_services_json} ); do                               \
        _service_destination_address=$( ${cmd_echo} ${service} | ${cmd_jq} -r '.destination.address' ); \
        _service_destination_port=$( ${cmd_echo} ${service} | ${cmd_jq} -r '.destination.port' );   \
        _service_source_port=$( ${cmd_echo} ${service} | ${cmd_jq} -r '.source.port' );             \
        ${cmd_printf} "HiddenServicePort ${_service_source_port} ${_service_destination_address}:${_service_destination_port}\n"; \
      done;                                                                                         \

      ${cmd_printf} "\n";                                                                           \
    done
)

# relay ports
# accounting
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ${_relay_accounting_enable} ]] &&                                                         \
       [[ ${_relay_accounting_period} == "month" ]] &&                                              \
       [[ ! -z ${_relay_accounting_amount} ]] &&                                                    \
       [[ ! -z ${_relay_accounting_day} ]] &&                                                       \
       [[ ! -z ${_relay_accounting_time} ]]; then                                                   \
       ${cmd_printf} AccountingMax ${_relay_accounting_amount} GB                                   \
       ${cmd_printf} AccountingStart month ${_relay_accounting_day} ${_relay_accounting_time};      \
    elif [[ ${_relay_enable} ]] &&                                                                  \
       [[ ${_relay_accounting_enable} ]] &&                                                         \
       [[ ${_relay_accounting_period} == "day" ]] &&                                                \
       [[ ! -z ${_relay_accounting_amount} ]] &&                                                    \
       [[ ! -z ${_relay_accounting_time} ]]; then                                                   \
       ${cmd_printf} AccountingMax ${_relay_accounting_amount} GB                                   \
       ${cmd_printf} AccountingStart dat ${_relay_accounting_time};                                 \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# address
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ! -z ${_relay_address} ]]; then                                                           \
       ${cmd_printf} Address ${_relay_address} NoListen;                                            \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi
)                   

# bridge
BridgeRelay ${_relay_bridge_enable}
PublishServerDescriptor ${_relay_bridge_descriptor}

# contact
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ${_relay_contact_enable} ]] &&                                                            \
       [[ ! -z ${_relay_contact_email} ]] &&                                                        \
       [[ -z ${_relay_contact_gpg} ]]; then                                                         \
       ${cmd_printf} ContactInfo ${_relay_contact_email};                                           \
    elif [[ ${_relay_enable} ]] &&                                                                  \
       [[ ${_relay_contact_enable} ]] &&                                                            \
       [[ ! -z ${_relay_contact_email} ]] &&                                                        \
       [[ ! -z ${_relay_contact_gpg} ]]; then                                                       \
       ${cmd_printf} ContactInfo ${_relay_contact_gpg} ${_relay_contact_email};                     \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# dirport
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ${_relay_dirport_enable} ]] &&                                                            \
       [[ ! -z ${_relay_dirport_address} ]] &&                                                      \
       [[ ! -z ${_relay_dirport_advertise} ]] &&                                                    \
       [[ ! -z ${_relay_dirport_frontpage} ]] &&                                                    \
       [[ ! -z ${_relay_dirport_listen} ]]; then                                                    \
       ${cmd_printf} DirPort ${_relay_dirport_advertise} NoListen                                   \
       ${cmd_printf} DirPort ${_relay_dirport_address}:${_relay_dirport_listen} NoAdvertise;        \
       ${cmd_printf} DirPortFrontPage ${_relay_dirport_frontpage};                                  \
    elif [[ ${_relay_enable} ]] &&                                                                  \
       [[ ${_relay_dirport_enable} ]] &&                                                            \
       [[ ! -z ${_relay_dirport_address} ]] &&                                                      \
       [[ ! -z ${_relay_dirport_advertise} ]] &&                                                    \
       [[ ! -z ${_relay_dirport_listen} ]]; then                                                    \
       ${cmd_printf} DirPort ${_relay_dirport_advertise} NoListen;                                  \
       ${cmd_printf} DirPort ${_relay_dirport_address}:${_relay_dirport_listen} NoAdvertise;        \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# exitpolicies
$(  _relay_exitpolicy_string=;                                                                      \
    _i=0;                                                                                           \
    if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ${_exitpolicies_count} > 0 ]]; then                                                       \
      for exitpolicy in $( ${cmd_echo} ${_exitpolicies_json} ); do                                  \
        [[ ${_i} > 0 ]] && _relay_exitpolicy_string=${_relay_exitpolicy_string}\,;                  \
        _relay_exitpolicy_ip=$( ${cmd_echo} ${exitpolicy} | ${cmd_jq} -r '.ip' );                   \
        _relay_exitpolicy_port_start=$( ${cmd_echo} ${exitpolicy} | ${cmd_jq} -r '.port.start' );   \
        _relay_exitpolicy_port_stop=$( ${cmd_echo} ${exitpolicy} | ${cmd_jq} -r '.port.stop' );     \
        _relay_exitpolicy_rule=$( ${cmd_echo} ${exitpolicy} | ${cmd_jq} -r '.rule' );               \
        if [[ ! -z ${_relay_exitpolicy_ip} ]] &&                                                    \
           [[ ! -z ${_relay_exitpolicy_port_start} ]] &&                                            \
           [[ ! -z ${_relay_exitpolicy_port_stop} ]] &&                                             \
           [[ ${_relay_exitpolicy_port_start} == ${_relay_exitpolicy_port_stop} ]] &&               \
            (                                                                                       \
              [[ ${_relay_exitpolicy_rule} == "accept" ]] ||                                   \
              [[ ${_relay_exitpolicy_rule} == "deny" ]]                                        \
            ); then                                                                                 \
            _relay_exitpolicy_string=${_relay_exitpolicy_string}ExitPolicy ${_relay_exitpolicy_rule} ${_relay_exitpolicy_ip}:${_relay_exitpolicy_port_start}; \
        elif [[ ! -z ${_relay_exitpolicy_ip} ]] &&                                                  \
           [[ ! -z ${_relay_exitpolicy_port_start} ]] &&                                            \
           [[ ! -z ${_relay_exitpolicy_port_stop} ]] &&                                             \
           [[ ${_relay_exitpolicy_port_start} != ${_relay_exitpolicy_port_stop} ]] &&               \
            (                                                                                       \
              [[ ${_relay_exitpolicy_rule} == "accept" ]] ||                                   \
              [[ ${_relay_exitpolicy_rule} == "deny" ]]                                        \
            ); then                                                                                 \
            _relay_exitpolicy_string=${_relay_exitpolicy_string}${_relay_exitpolicy_rule} ${_relay_exitpolicy_ip}:${_relay_exitpolicy_port_start}-${_relay_exitpolicy_port_stop}; \  
        fi;                                                                                         \
      done;                                                                                         \
      ${cmd_printf} ExitPolicy ${_relay_exitpolicy_string};                                               \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi  
)

# myfamily
$(  _family_string=;                                                                                \
    _i=0;                                                                                           \
    if [[ ${_families_count} > 0 ]]; then                                                           \
      for family in $( ${cmd_echo} ${_families_json} ); do                                          \
        [[ ${_i} > 0 ]] && _family_string=${_family_string}\,                                       \
        _family_string=${_family_string}${family};                                                  \
        (( _i++ ));                                                                                 \
      done;                                                                                         \
      ${cmd_printf} MyFamily ${_family_string};                                                     \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi  
)

# nickname
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ! -z ${_nickname} ]]; then                                                                \
       ${cmd_printf} "NickName ${_nickname}";                                                       \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# orport
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ${_relay_orport_enable} ]] &&                                                             \
       [[ ! -z ${_relay_orport_address} ]] &&                                                       \
       [[ ! -z ${_relay_orport_advertise} ]] &&                                                     \
       [[ ! -z ${_relay_orport_listen} ]]; then                                                     \
       ${cmd_printf} ORPort ${_relay_listen} NoListen                                               \
       ${cmd_printf} ORPort ${_relay_address}:${_relay_advertise} NoAdvertise;                      \
    elif [[ ${_relay_enable} ]] &&                                                                  \
       [[ ${_relay_orport_enable} ]] &&                                                             \
       [[ ! -z ${_relay_listen} ]]; then                                                            \
       ${cmd_printf} "ORPort ${_relay_orport_bind}";                                                \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# outboundbindaddress
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ! -z ${_outboundbindaddress} ]]; then                                                     \
       ${cmd_printf} "OutboundBindAddress ${_outboundbindaddress}";                                 \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# relaybandwithburst
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ! -z ${_relaybandwithburst} ]]; then                                                      \
       ${cmd_printf} "RelayBandwithBurst ${_relaybandwithburst}";                                   \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)

# relaybandwithrate
$(  if [[ ${_relay_enable} ]] &&                                                                    \
       [[ ! -z ${_relaybandwithrate} ]]; then                                                       \
       ${cmd_printf} "RelayBandwithRate ${_relaybandwithrate}";                                     \
    else                                                                                            \
       ${cmd_printf} "# none";                                                                      \
    fi                                                                                              \
)
EOF.torrc

    [[ $( /usr/local/bin/tor -f ${_path}/torrc --verify-config ) ]] || (( _error_count++ ))

    [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

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