move.coriolis.list.active() {
  # local variables
  local _count=0

  # argument variables
  local _short=${false}

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in      
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -s | --short )
        _output=name
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  if [[ ! -z ${_profile} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '[ .[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' ) ]' )

  else
    (( _error_count++ ))

  fi

  # itterate active profiles
  for profile in $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].name ' ); do

    # itterate active endpoints
    for endpoint in $( move.coriolis.list.endpoints --profile ${profile} | ${cmd_jq} -c '.[]' ); do
      if [[ ! -z ${_output} ]]; then
        case ${_output} in
          name                  ) ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.endpoint'                                                                ;;
          table                 )
            ${cmd_echo}
            ${cmd_echo} Coriolis - Active Endpoints
        
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Profile"                             ${MOVE_PROFILE}

            # output settings
            ${cmd_printf} "------------------------------------------------------------------------\n"
            ${cmd_printf} "%-2s %-30s : %-20s\n" "$(( ${_count} + 1 ))" "Endpoint Name" $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.endpoint  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Auth Plugin"                       $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.auth.plugin  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Auth URL"                          $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.api.url  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Certificate"                       $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.cert  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Identity API Version"              $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.api.version  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Interface"                         $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.api.interface  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Endpoint Type"                     $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.api.endpoint_type  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Region Name"                       $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.region  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Password"                          "**********"
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Project Domain Name"               $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.auth.project.domain.name  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Project Name"                      $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.project.name  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Project User Domain Name"          $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.auth.user.domain.name  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Tenant Name"                       $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.tenant.name  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "User Name"                         $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.auth.user.name  | if( . == null ) then "unset" else . end' )
          ;;

        esac
      else
        ${cmd_echo} ${_json} | ${cmd_jq} -sc

      fi

      (( _count++ ))
    done
  done

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}