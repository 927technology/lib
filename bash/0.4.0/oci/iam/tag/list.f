oci.iam.tag.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_tag_namespace=0
  local _count_tag=0
  local _json="{}"
  local -a _json_tag=
  local _id_tag_namespace=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json_tag_namespace=

  # argument variables
  local _id=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -i  | --id )
        shift
        _id="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # get namespaces
  _json_tag_namespace=$( oci.iam.tag_namespace.list --id ${_id} --profile ${_profile} | ${cmd_jq} -c )

  # itterate tag_namespaces by id
  for tag_namespace in $( ${cmd_echo} ${_json_tag_namespace} | ${cmd_jq} -c '.[]' ); do
    # get the availability domain name
    _id_tag_namespace=$( ${cmd_echo} ${tag_namespace} | ${cmd_jq} -r '.id')

    # get tags in each availability domain
    for tag in $( ${cmd_oci} iam tag list --profile ${_profile} --tag-namespace-id ${_id_tag_namespace} | ${cmd_jq} -c '.data[]' ); do
      # add tag to json
      _json_tag[${_count_tag}]="${tag}"
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      # add tag namespace to tag in json
      _json_tag[${_count_tag}]=$( json.set --json ${_json_tag[${_count_tag}]} --key .\"tag-namespace\" --value "$( ${cmd_echo} ${_json_tag_namespace} | ${cmd_jq} -c '.['${_count_tag_namespace}']' )" )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

      (( _count_tag++ ))
    done
    (( _count_tag_namespace++ ))
  done
  
  # build json list form _json_tag array
  _json=$( ${cmd_echo} "${_json_tag[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}