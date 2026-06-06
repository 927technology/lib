move.get.secrets() {
  # local variables
  local _json="{}"
  local _path=~move/move

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _profile=
  local _verbose=${false}

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
      -v | --verbose )
        _verbose=${true}
      ;;
     esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && return ${exit_crit}

  shell.log "${FUNCNAME} - [SECRET]    Fetching Secrets"

  # _json="$(                             \
  #   rapid.get.credentials               \
  #     --alternate-id $(                 \
  #       move.list.profiles              \
  #         --output vault                \
  #         --profile ${_profile}         \
  #       )                               \
  #     --key $(                          \
  #       move.list.profiles              \
  #         --output rapid_key            \
  #         --profile ${_profile}         \
  #     )                                 \
  #     --secret $(                       \
  #       move.list.profiles              \
  #         --output rapid_secret         \
  #         --profile ${_profile}         \
  #     )                                 \
  #     --filter 1mc                      \
  #     || (( _error_count++ ))           \
  # )"

  _json=$( openssl.list.file --file ${_path}/${_profile}/vault/vault.enc --key ${_path}/${_profile}/vault/vault.key | ${cmd_jq} -c )

  # export secrets to environment
  if ${cmd_echo} ${_json} | is_json >/dev/null 2>&1; then
    shell.log "${FUNCNAME} - [SECRET]    Unsetting"
    unset MOVE_SECRETS

    shell.log "${FUNCNAME} - [SECRET]    Setting"
    export MOVE_SECRETS="${_json}"
  
  else
    shell.log "${FUNCNAME} - [ERROR]    Problem validating secrets"
    (( _error_count++ ))
  
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}