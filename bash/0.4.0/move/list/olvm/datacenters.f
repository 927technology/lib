move.list.olvm.datacenters() {
  # local variables
  local _json=
  local _path=~move/move

  # argument variables
  local _datacenter=
  local _datacenter_short=
  local _display=
  local _vlan=
  local _short=${false}

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -d  | --display )
        shift
        _display="${1}"
      ;;
      -df | --datacenter )
        shift
        _name="${1}"
      ;;
      -ds | --datacenter-short )
        shift
        _name_short="${1}"
      ;;
      -v  | --vlan )
        shift
        _vlan="${1}"
      ;;
    esac
    shift
  done

  # main
  if    [[ ! -z ${_name} ]]                         && \
        [[ ! -z ${_vlan} ]]                         && \
        [[ -d ${_path}/datacenters ]]; then

    _json=$( ${cmd_cat} ${_path}/datacenters/*.json | ${cmd_jq} '. | select((.datacenter.full == "'${_name}'" ) and .vlan == '${_vlan}' )' )

  elif  [[ ! -z ${_name_short} ]]                   && \
        [[ ! -z ${_vlan} ]]                         && \
        [[ -d ${_path}/datacenters ]]; then

    # _json=$( ${cmd_cat} ${_path}/datacenters/*.json | ${cmd_jq} '. | select((.datacenter.short == "'${_name}'" ) and .vlan == '${_vlan}' )' )
    _json=$( ${cmd_cat} ${_path}/datacenters/*.json | ${cmd_jq} '. | select((.datacenter.short == "'${_name_short}'" ) and .vlan == '${_vlan}' )' )

  else
    _json=$( ${cmd_cat} ${_path}/datacenters/*.json  )
    # _exit_code=${exit_crit}
  
  fi

  # output display options
  if    [[ ! -z ${_display} ]]; then
    
    case ${_display} in
      id ) 
        ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.endpoint.network.id'
      
      ;;
      network_name ) 
        ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.endpoint.network.name'

      ;;
      vlan )
        ${cmd_echo} ${_json} | ${cmd_jq} -r '.vlan'

      ;;
    esac

  else
    ${cmd_echo} ${_json} | ${cmd_jq} -s

  fi      

  # exit
  return ${_exit_code}
}