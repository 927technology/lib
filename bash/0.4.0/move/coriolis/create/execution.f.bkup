move.coriolis.create.execution() {
  # edited
  # chris murray
  # 20251120

  # description
  # creates coriolis execution set in the ${_path}/${_profile}/transfers/${_name}.json 
  # writes output to ${_path}/${_profile}/execution/${_id}.json as json -c format

  # local variables
  local _folder=
  local _instance=
  local _json="{}"
  local _path=~move/move
  local _virtual_center=
  
  # argument variables
  local _filter=
  local _name=
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter="${1}"
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  
  # set vm json
  _json=$( move.list.vms --name ${_name} --profile ${_profile} || (( _error_count++ )) )

  # parse variables from vm json
  _folder=$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.folder.name' )
  _virtual_center=$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.server.datacenter' )
  _instance=${_virtual_center}/${_folder}/${_name}
  
  # parse transfer id from coriolis cache
  _id_transfer=$( coriolis.list.transfers | ${cmd_jq} -r '.[-1] | select(.Instances == "'${_instance}'" ).ID' || (( _error_count++ )) )

  # set execution in coriolis server
  _json=$( ${cmd_coriolis} execution create --format json ${_id_transfer} || (( _error_count++ )) )

  # write execution output to file
  ${cmd_echo} "${_json}" > ${_path}/${_profile}/executions/$( ${cmd_echo} ${network} | ${cmd_jq} -r '.ID' ).json
  ${cmd_ln} -fs $( ${cmd_echo} ${network} | ${cmd_jq} -r '.ID' ).json ${_path}/${_profile}/executions/${_name}

  # exit
  [[ ${_error_count} != 0 ]] || _exit_code=${exit_crit} && _exit_code=${exit_ok}
  return ${_exit_code}
}