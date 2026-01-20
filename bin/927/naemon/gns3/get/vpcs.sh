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
. ${_lib_root}/date.l
. ${_lib_root}/gns3.l
. ${_lib_root}/json.l
. ${_lib_root}/hash.l

# argument variables
_file=
_host=
_project=
_type=

# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=
node=

# local variables
_id=
_json="{}"
_json_exit="{}"
_project_id=

# parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -f  | --file )
        shift
        _file="${1}"
      ;;
      -h  | --host )
        shift
        _host="${1}"
      ;;
      -P  | --project )
        shift
        _project="${1}"
      ;;
      -t | --type )
        shift
        _type="${1}"
    esac
    shift
  done

# main
# echo $_host

if  [[ ! -z ${_file} ]]     && \
    [[ ! -z ${_host} ]]     && \
    [[ ! -z ${_project} ]]  && \
    [[ ! -z ${_type} ]]; then
  _project_id=$( gns3.get.projects --host ${_host} --output id --filter ${_project} )


  for node in $( gns3.get.project.${_type} --host ${_host} --project ${_project_id} | ${cmd_jq} -c '. | sort_by(.name) | .[]' ); do
    echo test
    # reset loop variables
    _id=
    _json="{}"
    _json_exit="{}"

    _id=$( ${cmd_echo} ${node} | ${cmd_jq} -r '.node_id' )
    
    _json=$( json.set --json ${_json} --key .ops.date --value $( date.epoch ) )

    [[ ! -d ${_file}/927/ops/gns3/${_type}/${_project_id} ]] && ${cmd_mkdir} --parents ${_file}/927/ops/gns3/${_type}/${_project_id}


    if [[ -f ${_file}/927/ops/gns3/${_type}/${_project_id}/${_id}.json ]]; then
      #hash the outputs
      if [[ $( ${cmd_echo} ${node} | hash.sha256 ) != $( ${cmd_cat} ${_file}/927/ops/gns3/${_type}/${_project_id}/${_id}.json | ${cmd_jq} '.data' | hash.sha256 ) ]]; then
        # ${cmd_echo} "${_json}" > ${_file}/927/ops/gns3/${_type}/${_project_id}/${_id}.json
        _exit_code=${exit_warn}
        _json_exit=$( json.set --json ${_json_exit} --key .ops.change --value ${true} )

      else
        _exit_code=${exit_ok}
        _json_exit=$( json.set --json ${_json_exit} --key .ops.change --value ${false} )
      fi

    fi
  done

fi

_exit_string="${_json_exit}"

# exit
[[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

${cmd_echo} "${_exit_string}"
exit ${_exit_code}
