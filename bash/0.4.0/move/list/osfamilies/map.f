move.list.osfamilies.map() {
  # local variables
  local _path=~move/move

  # argument variables
  local _filter=
  local _id=
  local _name=
  local _short=${false}

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter="$( ${cmd_echo} "${1}" | lcase )"
      ;;
      -i | --id )
        _id=${true}
      ;;
      -n | --name )
        shift
        _name="${1}"
      ;;
      -s | --short )
        _short=${true}
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_name} ]] && \
      [[ -d ${_path}/osfamilies/ ]]; then
    
    if [[ ${_short} == ${true} ]]; then
      ${cmd_cat} ${_path}/osfamilies/*.json  | ${cmd_jq} '. | select(.vsphere.name == "'${_name}'")' | ${cmd_jq} -s | ${cmd_jq} -r '.[0].olvm.name' 

    else
      ${cmd_cat} ${_path}/osfamilies/*.json  | ${cmd_jq} '. | select(.vsphere.name == "'${_name}'")' | ${cmd_jq} -s  

    fi


  elif  [[ ! -z ${_filter} ]]; then
    if    [[ ${_short} == ${true} ]]; then
      ${cmd_cat} ${_path}/osfamilies/*.json | ${cmd_jq} '. | select( (.vsphere.name? | ascii_downcase ) | match("'"${_filter}"'"))' | ${cmd_jq} '.vsphere.name | ascii_downcase' | ${cmd_jq} -s '. | unique | sort' | ${cmd_jq} -r '.[]'
    
    elif  [[ ${_id} == ${true} ]]; then
      ${cmd_cat} ${_path}/osfamilies/*.json | ${cmd_jq} '. | select( (.vsphere.name? | ascii_downcase ) | match("'"${_filter}"'"))' | ${cmd_jq} -r '.id'
    
    else
      ${cmd_cat} ${_path}/osfamilies/*.json | ${cmd_jq} '. | select( (.vsphere.name? | ascii_downcase ) | match("'"${_filter}"'"))' | ${cmd_jq} -s

    fi

  elif [[ ${_short} == ${true} ]]; then
    ${cmd_cat} ${_path}/osfamilies/*.json | ${cmd_jq} -r '"\(.vsphere.name) -> \(.olvm.name)"'  

  else
    ${cmd_cat} ${_path}/osfamilies/*.json | ${cmd_jq} -s 

  fi

  # exit
  return ${_exit_code}
}