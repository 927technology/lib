#!/bin/bash

# global variables
_lib_version=0.4.0
_lib_root=/usr/local/lib/bash/${_lib_version}
_os_family=el

# command library
. ${_lib_root}/variables/cmd_${_os_family}.v

# variables
. ${_lib_root}/variables.l

# other libraries
. ${_lib_root}/gns3.l

# argument variables
_host=

# control variables
_error_count=0
_exit_code=${exit_unkn}
_exit_string=

# local variables
_json="{}"

# parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -h  | --host )
        shift
        _host="${1}"
      ;;
    esac
    shift
  done

# main
echo $_host

# exit
[[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

${cmd_echo} ${_exit_string}
exit ${_exit_code}
