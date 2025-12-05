927.ops.path.create.oci() {
  # description

  # argument variables
  local _group=
  local _owner=
  local _path=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _tag=927.create.ocipath

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -g | --group )
        shift
        _group="${1}"
      ;;
      -o | --owner )
        shift
        _owner="${1}"
      ;;    
      -p | --path )
        shift
        _path="${1}"
      ;;
    esac
    shift
  done

  # main
  # create .oci path
  shell.create.directory --directory ${_path}/.oci --group gearmand --mode 600 --owner gearmand


  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}