oci.iam.compartment.list() {
  # prerequisites
  # json/set
  
  # local variables
  local _id=
  local _json="{}"
  local _json_root="{}"
  local _length=0
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

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
  _json=$( ${cmd_oci} iam compartment list --all --compartment-id ${_id} --profile ${_profile} | ${cmd_jq} -c '.data' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # get length of json list
  _length=$( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' )

  # build root compartment json object
  _json_root=$( json.set --json "${_json_root}" --key .\"compartment-id\"                   )
  _json_root=$( json.set --json "${_json_root}" --key .\"defined-tags\"     --value {}      )
  _json_root=$( json.set --json "${_json_root}" --key .description          --value "root"  )
  _json_root=$( json.set --json "${_json_root}" --key .\"freeform-tags\"    --value {}      )
  _json_root=$( json.set --json "${_json_root}" --key .id                   --value ${_id}  )
  _json_root=$( json.set --json "${_json_root}" --key .\"inactive-status\"                  )
  _json_root=$( json.set --json "${_json_root}" --key .\"is-accessible\"                    )
  _json_root=$( json.set --json "${_json_root}" --key .\"lifecycle-state\"  --value ACTIVE  )
  _json_root=$( json.set --json "${_json_root}" --key .name                 --value root    )
  _json_root=$( json.set --json "${_json_root}" --key .\"time-created\"                     )
 
  # add root object to compartments list
  _json=$( json.set --json "${_json}" --key .[${_length}] --value "${_json_root}" )

  # set exit string
  _exit_string="${_json}"

  # exit
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}