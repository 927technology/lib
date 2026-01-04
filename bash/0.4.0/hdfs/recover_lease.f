hdfs.recover_lease() {
  # description
  # attempt to recover hdfs file lease from json created by hdfs.blockin_decommission()
  # accepts 1 argument
  # -d | --dry-run outputs data with no changes (optional)
  # outputs json of run data
  # returns boolean success

  # variables
  local _count=0
  local _json=
  local _dry_run=${true}
  local _json=
  local _output=
  local _status=
  local _succeeded=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  while ${1} != ""; do
    case ${1} in
      -d | --dry-run )
        shift
        _dry_run=${1}
      ;;
    esac
    shift
  done

  # main
  # parse files blocking decommission
  _json=$( hdfs.blocking_decommission )

  # exit crit if empty json
  [[ -z "${_json}" ]] && return ${exit_crit}

  # attempt recovery
  for file in $( ${cmd_echo} "${_json}" -r '.files[].path' ); do
    # zero out loop variables
    _output=
    _status=
    _succeeded=${false}

    # populate loop variables
    if [[ ${_dry_run} == ${false} ]]; then
      _output=$( ${cmd_hdfs} debug recoverLease -path "${file}" 2>/dev/null || (( _error_count++ )) )
      _status=$( ${cmd_echo} ${_output} | ${cmd_awk} '{print $2}' )

      # set status of _succeeded
      [[ $( ${cmd_echo} ${_status} ) == SUCCEEDED ]] && _succeeded=${true} || (( _error_count++ ))
    fi

    # add succeeded to json
    _json=$( json.set --json "${_json}" --key .files[${_count}].succeeded --value ${_succeeded} || (( _error_count++ )) )

    (( _count++))
  done

  # add error count to json string
  _json=$( set.json --json "${_json}" --key .error.count --value ${_error_count} )
  _json=$( set.json --json "${_json}" --key .dry_run --value ${_dry_run} )

  # set exit code
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  ${cmd_echo} ${_json}
  return ${exit_code}
}