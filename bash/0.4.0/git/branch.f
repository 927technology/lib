function git.branch {
  # Description repo name, returns string branch name.
  # accepts  1 arg.

  # depends on
  ## 0.4.x/git/branch.f

  # local variables
  local _current_branch=
  local _err_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _repo=

  # parse command arguments
  ## none

  # main
  _current_branch=$( ${cmd_git} branch --show-current )               || (( _err_count++ ))

  if [[ -z ${_current_branch} ]]; then
    (( _err_count++ ))
  else
    _exit_string=${_current_branch}
  fi

  [[ ${_err_count} > 0 ]]                                             && _exit_string=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}