hbase.shell.intel() {
  # description

  # dependancies
  # yes what are they?

  # argument variables
  # local _tmp=$( mktemp -d )

  # local variables
  local _json=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  
  # parse arguments
  # none

  # main
  # make tmp path for java if missing
  # [[ ! -d ~move/tmp ]] && { ${cmd_mkdir} -p ~move/tmp || ((_error_count++ )); }
  

  # export java options
  # export _JAVA_OPTIONS=-Djava.io.tmpdir=~move/tmp || ((_error_count++ ))
  export _JAVA_OPTIONS=-Djava.io.tmpdir=/root/tmp
  export JAVA_HOME=/usr/lib/jvm/java
  # export _JAVA_OPTIONS=-Djava.io.tmpdir=${_tmp} || ((_error_count++ ))

  # query hbase
  _json=$( ${cmd_hbase} shell ${_lib_root}/hbase/shell/intel.rb 2>/var/log/sepsis/hbase.log | ${cmd_jq} -c )
  # _json=$( /usr/bin/hbase shell /usr/local/lib/bash/0.4.0/hbase/shell/intel.rb 2>/dev/null | ${cmd_jq} -c )

  # /usr/bin/hbase shell /usr/local/lib/bash/0.4.0/hbase/shell/intel.rb > /var/log/sepsis/hbase.log 2>&1

  _exit_string="${_json}"
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}