. ${_lib_root}/927/variables/bools.v
. ${_lib_root}/927/variables/exits.v

case $( uname -a ) in
  Darwin )
    . ${_lib_root}/927/variables/cmd/darwin.v

  ;;
  Linux )
    if    [[ -f /etc/redhat-release ]]; then
      . ${_lib_root}/927/variables/cmd/el.v

    elif  [[ -f /etc/lsb-release ]]; then
      . ${_lib_root}/927/variables/cmd/debian.v

    fi
  ;;
esac