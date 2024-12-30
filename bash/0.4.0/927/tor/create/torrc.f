927.ops.create.torrc () {
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
  local _template=${false}


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # commands variables
  local _name=
  local _line=

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
    [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*

    _daemon=$(                                  ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .daemon )                                   | if( . == '${true}' ) then '${true}' else '${false}' end' )


    _socks_accept_enable=$(                     ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.accept.enable )                      | if( . == null ) then "" else . end' )
    _socks_accept_prefix=$(                     ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.accept.prefix )                      | if( . == null ) then "" else . end' )
    _socks_accept_subnet=$(                     ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.accept.subnet )                      | if( . == null ) then "" else . end' )
    
    _log_debug_enable=$(                        ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .log.debug.enable )                         | if( . == null ) then "" else . end' )
    _log_debug_file=$(                          ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .log.debug.file )                           | if( . == null ) then "" else . end' )
    _log_debug_output=$(                        ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .log.debug.output )                         | if( . == null ) then "" else . end' )
    
    _log_notices_enable=$(                      ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .log.notices.enable )                         | if( . == null ) then "" else . end' )
    _log_nogices_file=$(                        ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .log.notices.file )                           | if( . == null ) then "" else . end' )
    _log_notices_output=$(                      ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .log.notices.output )                         | if( . == null ) then "" else . end' )
    

    _socks_primary_address=$(                   ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.primary.address )                    | if( . == null ) then "" else . end' )
    _socks_primary_port=$(                      ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.primary.port )                       | if( . == null ) then "" else . end' )
    _socks_accept_enable=$(                     ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.reject.enable )                      | if( . == null ) then "" else . end' )
    _socks_accept_prefix=$(                     ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.reject.prefix )                      | if( . == null ) then "" else . end' )
    _socks_accept_subnet=$(                     ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.reject.subnet )                      | if( . == null ) then "" else . end' )
    _socks_secondary_address=$(                 ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.secondary.address )                  | if( . == null ) then "" else . end' )
    _socks_secondary_port=$(                    ${cmd_echo} ${_json}  | ${cmd_jq} -r  'try( .socks.secondary.port )                     | if( . == null ) then "" else . end' )
    

    ${cmd_echo} Writing Config: ${_path}/torrc
    ${cmd_cat} << EOF.torrc > ${_path}/torrc

  $( [[ ! -z ${_socks_primary_port} ]]                                                                    \
    && ${cmd_printf} "SocksPort ${_socks_port}" )

  $( [[ ! -z ${_socks_secondary_address} ]] &&                                                            \
     [[ ! -z ${_socks_secondary_port} ]]                                                                  \
    && ${cmd_printf} "SocksPort ${_sockes_secondary_address}:${_socks_secondary_port}" )

  $( ( [[ ! -z ${_socks_accept_subnet} ]] && [[ ! -z ${_socks_accept_prefix} ]] ) &&                      \
       [[ ${_socks_accept_enable} == ${true} ]]                                                           \
    && ${cmd_printf} "SocksPolicy accept ${_socks_accept_subnet}/${_socks_accept_prefix}" )

  $( ( [[ ! -z ${_socks_reject_subnet} ]] && [[ ! -z ${_socks_reject_prefix} ]] ) &&                      \
       [[ ${_socks_reject_enable} == ${true} ]]                                                           \
    && ${cmd_printf} "SocksPolicy reject ${_socks_accept_subnet}/${_socks_accept_prefix}" )

  $( ( [[ ! -z ${_log_debug_file} ]] && [[ ! -z ${_log_debug_output} ]] ) &&                              \
       [[ ${_log_debug_enable} == ${true} ]]                                                              \                       \
    && ${cmd_printf} "Log debug file ${_log_debug_file}" )

  $( ( [[ ! -z ${_log_debug_file} ]] && [[ ! -z ${_log_debug_output} ]] ) &&                              \
       [[ ${_log_debug_enable} == ${true} ]]                                                              \                       \
    && ${cmd_printf} "Log debug  ${_log_debug_output}" )

  $( ( [[ ! -z ${_log_notices_file} ]] && [[ ! -z ${_log_notices_output} ]] ) &&                          \
       [[ ${_log_notices_enable} == ${true} ]]                                                            \                       \
    && ${cmd_printf} "Log notice file ${_log_notice_file}" )

  $( ( [[ ! -z ${_log_notices_file} ]] && [[ ! -z ${_log_notices_output} ]] ) &&                          \
       [[ ${_log_notices_enable} == ${true} ]]                                                            \                       \
    && ${cmd_printf} "Log notice  ${_log_notice_output}" )

RunAsDaemon ${_daemon}

DataDirectory /var/lib/tor

#ControlPort 9051

#HiddenServiceDir /var/lib/tor/hidden_service/
#HiddenServicePort 80 127.0.0.1:80

HiddenServiceDir /var/lib/tor/secure
HiddenServicePort 8080 192.168.1.250:8080

#ORPort 9001

#Address noname.example.com

# OutboundBindAddress 10.0.0.5

#Nickname ididnteditheconfig

#RelayBandwidthRate 100 KB  # Throttle traffic to 100KB/s (800Kbps)
#RelayBandwidthBurst 200 KB # But allow bursts up to 200KB/s (1600Kbps)

#AccountingMax 4 GB
#AccountingStart day 00:00
#AccountingStart month 3 15:00

#ContactInfo Random Person <nobody AT example dot com>
#ContactInfo 0xFFFFFFFF Random Person <nobody AT example dot com>

#DirPort 9030 # what port to advertise for directory connections
#DirPort 80 NoListen
#DirPort 127.0.0.1:9091 NoAdvertise
#DirPortFrontPage /etc/tor/tor-exit-notice.html

#MyFamily $keyid,$keyid,...

#ExitPolicy accept *:6660-6667,reject *:* # allow irc ports but no more
#ExitPolicy accept *:119 # accept nntp as well as default exit policy
#ExitPolicy reject *:* # no exits allowed

#BridgeRelay 1
#PublishServerDescriptor 0





EOF.torrc

    [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
    ${cmd_sed} -i '/^[[:space:]]*$/d' ${_path}/${_file_name}.cfg

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