coriolis.list.endpoints.storage() {
  # local variables
  local _json=
  local _path=~move/coriolis

  # argument variables
  local _filter=
  local _id=${false}
  local _short=${false}

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} ${1} | lcase )
      ;;
      -i | --id )
        _id=${true}
      ;;
      -s | --short )
        _short=${true}
      ;;
    esac
    shift
  done

  # main
  if    [[ ! -z ${_filter} ]]; then
    if [[ ${_short} == ${true} ]]; then
      ${cmd_cat} ${_path}/endpoints/storage/*.json | ${cmd_jq} '. | select( (.name.full? | ascii_downcase ) | match("'${_filter}'"))' | ${cmd_jq} '"\( .olvm.datacenter | ascii_downcase )/\( .olvm.domain | ascii_downcase )"' | ${cmd_jq} -s '. | unique | sort' | ${cmd_jq} -r '.[]'
    
    elif  [[ ${_id} == ${true} ]]; then
      ${cmd_cat} ${_path}/endpoints/storage/*.json | ${cmd_jq} '. | select( (.name.full? | ascii_downcase ) | match("'${_filter}'"))' | ${cmd_jq} -r '.id'
    
    else
      ${cmd_cat} ${_path}/endpoints/storage/*.json | ${cmd_jq} '. | select( (.name.full? | ascii_downcase ) | match("'${_filter}'"))' | ${cmd_jq} -s

    fi

  elif  [[ ${_short} == ${true} ]]; then
    ${cmd_cat} ${_path}/endpoints/storage/*.json  | ${cmd_jq} '"\( .olvm.datacenter | ascii_downcase )/\( .olvm.domain | ascii_downcase )"' | ${cmd_jq} -s '. | unique | sort' | ${cmd_jq} -r '.[]'
  
  else
    ${cmd_cat} ${_path}/endpoints/storage/*.json  | ${cmd_jq} -s

  fi


  # exit
  return ${_exit_code}
}