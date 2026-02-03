function naemon.get.ifs() {
  # delete
  _lib_root=/usr/local/lib/bash/0.4.0
  . ${_lib_root}/variables/cmd_el.v
  . ${_lib_root}/json.l
  . ${_lib_root}/variables.l
  . ${_lib_root}/standard.l


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


  local _count=0
  local _json="{}"
  local _snmp_community="${1}"
  local _host="${2}"


  # /bin/snmpwalk -Onq -v2c -c ${_snmp_community} ${_host} .1.3.6.1.2.1.2.2 > ${_tmp_file}

  echo ${_snmp_path}/${_name}/snmp 
  ${cmd_grep} ^.1.3.6.1.2.1.2.2.1.1.[0-9] ${_snmp_path}/${_name}/snmp
  
  ${cmd_grep} ^.1.3.6.1.2.1.2.2.1.1.[0-9] ${_snmp_path}/${_name}/snmp | \
    while IFS=' ' read -r oid value; do
      _json="{}"

     _json=$( json.set --json "${_json}" --key .index --value ${value} )
     _json=$( json.set --json "${_json}" --key .description  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.2.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.type  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.3.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .status.admin  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.7.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .status.operatinal  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.8.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.in.error  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.4.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.speed  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.5.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.lastchange  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.9.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )

     _json=$( json.set --json "${_json}" --key .if.in.octet  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.10.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.in.unicast  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.11.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.in.nonunicast  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.12.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.in.discard  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.13.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.in.error_all  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.14.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )

     _json=$( json.set --json "${_json}" --key .if.out.octet  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.16.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )

     _json=$( json.set --json "${_json}" --key .if.alias  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.18.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.out.discard  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.19.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.out.error_all  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.20.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.out.qlen  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.21.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.specific  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.22.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )
     _json=$( json.set --json "${_json}" --key .if.highspeed  --value $( ${cmd_grep} .1.3.6.1.2.1.2.2.1.23.${value} ${_tmp_file} | ${cmd_awk} -F" " '{print $2}' ) )


      (( _count++ ))

      echo $_json | jq

    done
}
