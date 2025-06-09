shell.get_version() {
  # local variables
  local _json="{}"
  local _version=
  local _version_major=
  local _version_minor=
  local _version_patch=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  _json=$( json.set --json "${_json}" --key ".value" --value "${SHELL}" )

  # main
  case ${SHELL} in
    "/bin/bash" )
      _version=$( ${SHELL} --version | ${cmd_head} -n 1 | ${cmd_awk} '{print $4}' | ${cmd_awk} -F"(" '{print $1}' )
      _version_major=$( ${cmd_echo} ${_version} | ${cmd_awk} -F"." '{print $1}' )
      _version_minor=$( ${cmd_echo} ${_version} | ${cmd_awk} -F"." '{print $2}' )
      _version_patch=$( ${cmd_echo} ${_version} | ${cmd_awk} -F"." '{print $3}' )

      _json=$( json.set --json "${_json}" --key ".detected"       --value "${true}" )
      _json=$( json.set --json "${_json}" --key ".path"           --value "${SHELL}" )
      _json=$( json.set --json "${_json}" --key ".value"          --value "bash" )
      _json=$( json.set --json "${_json}" --key ".version.full"   --value "${_version}" )
      _json=$( json.set --json "${_json}" --key ".version.major"  --value "${_version_major}" )
      _json=$( json.set --json "${_json}" --key ".version.minor"  --value "${_version_minor}" )
      _json=$( json.set --json "${_json}" --key ".version.patch"  --value "${_version_patch}" )
    ;;
    * )
      _json=$( json.set --json "${_json}" --key ".detected"       --value "${false}" )
      _json=$( json.set --json "${_json}" --key ".value"          --value "unknown" )
    ;;
  esac

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}