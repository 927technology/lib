move.stop.was() {
  # local variables
  _was_count_process=
  _was_count_error=0

  # argument variables
  local _host=
  local _password=
  local _username=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ "${1}" != "" ]]; do
    case "${1}" in
      -u | --username )
        shift
        _username="${1}"
      ;;
      -pw  | --password )
        shift
        _password="${1}"
      ;;
      -n | -h | --host | --name )
        shift
        _name="${1}"
      ;;
    esac
    shift
  done

  # main
  _was_count_process=$(
    sshpass                                 \
      -f ~/pass.txt                         \
        ssh                                 \
          -t                                \
          -p 22                             \
          -o "StrictHostKeyChecking no"     \
          ${_username}@pam.cernerasp.com    \
          root@${_name}                     \
            "                               \
              /usr/bin/ps -ef |             \
              /usr/bin/grep  ^wasadmin |    \
              /usr/bin/grep -c  \/opt\/websphere\/appserver\/java\/bin\/java  \
            "                               \
            2>/dev/null |                   \
            /usr/bin/tail -n +2             \
            || $(( _was_count_error ++ ))
  )
  
  shell.log "[WAS] Host: ${_name}, Count: ${_was_count_process} (${_was_count_error})"

}