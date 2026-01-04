move.create.network.map() {
  # local variables
  local _json=
  local _path=~move/move

  # argument variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  ${cmd_mkdir} -p ${_path}/networks
  
  for network in $( ${cmd_cat} ${_path}/migrations/vms/*.json | ${cmd_jq} '.networkadapters[].networkname | select(. != null)' | ${cmd_jq} -sr '. | unique | sort | .[]' ); do
    # zero out loop variables
    _json=


    _json=$( json.set --json ${_json} --key .vsphere.network --value ${network} )
    _json=$( json.set --json ${_json} --key .vsphere.hosts --value $( ${cmd_cat} ${_path}/migrations/vms/*.json | ${cmd_jq} '. | select(.networkadapters[].networkname == "'${network}'").name' | ${cmd_jq} -sc '. | unique | sort' ) )
    _json=$( json.set --json ${_json} --key .olvm.datacenter --value null )
    _json=$( json.set --json ${_json} --key .olvm.domain --value null )
    _json=$( json.set --json ${_json} --key .olvm.host --value null )
    _json=$( json.set --json ${_json} --key .olvm.vlan --value null )

    ${cmd_echo} $( date.pretty ) - Parsing network ${network}

    ${cmd_echo} ${_json} | ${cmd_jq} > ${_path}/networks/"${network}".json
    
  done

  _exit_string="${_json}"

  # exit
  return ${_exit_code}
}