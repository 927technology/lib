move.create.olvm.datacenters() {
  # local variables
  local _json=
  local _path=~move/move

  # argument variables
  local _datacenter=
  local _datacenter_short=
  local _vlan=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -df | --datacenter )
        shift
        _name="${1}"
      ;;
      -ds | --datacenter-short )
        shift
        _name_short="${1}"
      ;;
      -v | --vlan )
        shift
        _vlan="${1}"
      ;;
    esac
    shift
  done

  # main
  # create path
  ${cmd_mkdir} -p ${_path}/datacenters

  if  [[ ! -z ${_name}        ]]    && \
      [[ ! -z ${_name_short}  ]]    && \
      [[ ! -z ${_vlan}        ]]; then
 
    _json=$( json.set --json ${_json} --key .coriolis.endpoint.network.id --value $( coriolis.list.endpoints.networks --filter ${_name_short}_VL${_vlan} | ${cmd_jq} -r '.[0].endpoint.id' ) )
    _json=$( json.set --json ${_json} --key .coriolis.endpoint.network.name --value ${_name_short}_VL${_vlan} )
    _json=$( json.set --json ${_json} --key .datacenter.full --value ${_name} )
    _json=$( json.set --json ${_json} --key .datacenter.short --value ${_name_short} )
    _json=$( json.set --json ${_json} --key .vlan --value ${_vlan} )

    ${cmd_echo} ${_json} | ${cmd_jq} > ${_path}/datacenters/${_name_short}_VL${_vlan}.json
  fi

  return ${_exit_code}
}