function naemon.get.ifs() {
  # delete
  _lib_root=/usr/local/lib/bash/0.4.0
  . ${_lib_root}/variables/cmd_el.v
  . ${_lib_root}/json.l
  . ${_lib_root}/variables.l
  . ${_lib_root}/standard.l

  # local variables
  local _oid=.1.3.6.1.2.1.2.2.1

  # argument variables
  local _json="{}"
  local _name=
  local _snmp_path=/etc/naemon/snmp.d

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -n | --name )
        shift
        _name="${1}"
      ;;
      -sp | --snmp-path )
        shift
        _path="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ -f ${_snmp_path}/${_name}/snmp ]]; then
    # make if output diretory
    [[ ! -d ${_snmp_path}/${_name}/ifs ]] && { ${cmd_mkdir} --parents ${_snmp_path}/${_name}/ifs || (( _error_count++ )); }

    # loop interfaces
    ${cmd_grep} ^${_oid}.1.[0-9] ${_snmp_path}/${_name}/snmp | \
      while IFS=' ' read -r oid value; do
        _json="{}"


        # set interface stats
        _json=$( json.set --json "${_json}" --key .index             --value ${value} )
        _json=$( json.set --json "${_json}" --key .description       --value $( ${cmd_grep} ${_oid}.2.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.type           --value $( ${cmd_grep} ${_oid}.3.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .status.admin      --value $( ${cmd_grep} ${_oid}.7.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .status.operatinal --value $( ${cmd_grep} ${_oid}.8.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.in.error       --value $( ${cmd_grep} ${_oid}.4.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.speed          --value $( ${cmd_grep} ${_oid}.5.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.lastchange     --value $( ${cmd_grep} ${_oid}.9.${value} ${_snmp_path}/${_name}/snmp  | ${cmd_awk} -F" " '{print $2}' ) )

        _json=$( json.set --json "${_json}" --key .if.in.octet       --value $( ${cmd_grep} ${_oid}.10.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.in.unicast     --value $( ${cmd_grep} ${_oid}.11.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.in.nonunicast  --value $( ${cmd_grep} ${_oid}.12.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.in.discard     --value $( ${cmd_grep} ${_oid}.13.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.in.error_all   --value $( ${cmd_grep} ${_oid}.14.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )

        _json=$( json.set --json "${_json}" --key .if.out.octet      --value $( ${cmd_grep} ${_oid}.16.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )

        _json=$( json.set --json "${_json}" --key .if.alias          --value $( ${cmd_grep} ${_oid}.18.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.out.discard    --value $( ${cmd_grep} ${_oid}.19.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.out.error_all  --value $( ${cmd_grep} ${_oid}.20.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.out.qlen       --value $( ${cmd_grep} ${_oid}.21.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.specific       --value $( ${cmd_grep} ${_oid}.22.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )
        _json=$( json.set --json "${_json}" --key .if.highspeed      --value $( ${cmd_grep} ${_oid}.23.${value} ${_snmp_path}/${_name}/snmp | ${cmd_awk} -F" " '{print $2}' ) )

        # output interface stats to disk
        shell.log "${FUNCNAME} [WRITING] - ${_snmp_path}/${_name}/ifs/${value}.json"
        ${cmd_echo} ${_json} > ${_snmp_path}/${_name}/ifs/${value}.json

    done

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}
