function git.clean {
  # accepts 2 args 1 git repo name 2 expected branch.  uses global git_root. returns exit status and no output

  # depends on
  ## 0.4.x/git/branch.f

  # local variables
  local _branch=
  local _count=0
  local _current_branch=$( git.branch ${_repo} )
  local _err_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _repo=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -b | --branch )
        shift
        _branch="${1}"
      ;;
      -r | --repo )
        shift
        _repo="${1}"
      ;;

    esac
    shift
  done

  # main

  if [ -d ${git_root}/${_repo} ]; then
    # rebase error correction
    git.rebase.abort ${_repo}                                         || (( _err_count++ ))

    # checkout master
    if [[ "${_current_branch}" != "master" ]]; then
      ${cmd_git} -C ${git_root}/${_repo} checkout master              || (( _err_count++ ))
    fi 

    ${cmd_git} -C ${git_root}/${_repo} fetch                          || (( _err_count++ ))
    ${cmd_git} -C ${git_root}/${_repo} pull                           || (( _err_count++ ))
  fi

  [[ ${_err_count} > 0 ]]                                             && _exit_code=${exit_crit}

  # exit
  return ${_exit_code}
}