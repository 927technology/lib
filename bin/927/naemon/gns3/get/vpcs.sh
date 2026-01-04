#!/bin/bash

# because IFS sucks
IFS=$'\n'

# global variables
_lib_version=0.4.0
_lib_root=/usr/local/lib/bash/${_lib_version}
_os_family=el

# command library
. ${_lib_root}/variables/cmd_${_os_family}.v

# variables
. ${_lib_root}/variables.l

# other libraries
. ${_lib_root}/gns3.l

# argument variables
_host=
_project=

# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=

# local variables
_json="{}"

# parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -h  | --host )
        shift
        _host="${1}"
      ;;
      -P  | --project )
        shift
        _project="${1}"
      ;;
    esac
    shift
  done

# main
# echo $_host

if  [[ ! -z ${_host} ]]     && \
    [[ ! -z ${_project} ]]; then
  _json=$( gns3.get.project.vpcs --host ${_host} --project $( gns3.get.projects --host ${_host} --output id --filter ${_project} ) )


  _exit_string+="Count: $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' )"

  for vpc in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.[]' ); do
    # echo "$vpc"
    # echo
    _exit_string+="\n"
    _exit_string+=$( ${cmd_echo} ${vpc} | ${cmd_jq} -r '"\(.node_id) - \(.name)"' )
  done

fi



# _exit_string="${_json}"

# exit
[[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

${cmd_echo} -e ${_exit_string}
exit ${_exit_code}
