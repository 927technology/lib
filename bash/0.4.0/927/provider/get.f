927.provider.get () {
  # description
  # creates ops hosts stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # ifs
  IFS=$'\n'

  # argument variables
  local _profile=
  local _resource=



  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # variables
  local _json="{}"
  local _output=

  
  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -p | --profile )
        shift
        _profile=${1}
      ;;
      -P | --provider )
        shift
        case ${1} in
          oci | OCI )
            _provider=oci
          ;;
        esac
      ;;
      -r | --resource )
        shift
        _resource=${1}
      ;;
    esac
    shift
  done

  # main
  if [[ ! -z ${_resource} ]]  &&
     [[ ! -z ${_profile}  ]]  &&
     [[ ! -z ${_provider} ]]; then
    case ${_provider} in 
      oci )
        case ${_resource} in
          compartment | compartments )
            _output=$( ${cmd_oci} --profile ${_profile} iam compartment list --compartment-id-in-subtree true 2>/dev/null | ${cmd_jq} '.data[] | select( ( ."lifecycle-state" == "ACTIVE" ) and ( .description | contains("idcs") | not ) )' | ${cmd_jq} -s  )
          ;;
          drg | drgs )
            _output=$( ${cmd_oci} --profile ${_profile} network drg list 2>/dev/null | ${cmd_jq} -c '.data[] | select( ( ."defined-tags"."927-ops".managed == "true" ) and ( .description | contains("idcs") | not ) )' | ${cmd_jq} -s )
          ;;
        esac
      ;;
    esac
  fi

  [[ $( json.validate --json "_output" ) ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}


  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data   |=.+ '"${_output}" )

  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}