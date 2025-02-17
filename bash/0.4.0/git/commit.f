function git.commit {
  #accepts 1 args 1 git repo uses global git_root.  this will stage all untracked files and commit.

  # depends on
  ## none

  # local variables
  local _err_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _repo=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -r | --repo )
        shift
        _repo="${1}"
      ;;

    esac
    shift
  done
  
  # main

  if [ $( ${cmd_git} -C ${git_root}/${_repo} status | ${cmd_head} -n 2 | ${cmd_tail} -n -1 | ${_cmd_grep} -c ^"Your branch is up to date with \'origin/${_repo}\'" ) -eq 0 ]; then
    ${cmd_git} -C ${git_root}/${_repo} fetch                          || (( _err_count++ ))
    ${cmd_git} -C ${git_root}/${_repo} pull                           || (( _err_count++ ))      
    ${cmd_git} -C ${git_root}/${_repo} add -A .                       || (( _err_count++ ))
    ${cmd_git} -C ${git_root}/${_repo} commit -am "forced commit from script" || (( _err_count++ ))
  fi

  [[ ${_err_count} > 0 ]]                                             && _exit_code=${exit_crit}
  
  # exit
  return ${_exit_code}
}