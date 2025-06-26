oci.budgets.alert_rule.list() {
  # dependancies
  # oci/budgets/budget/list.f

  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_budget=0
  local _count_alert_rule=0
  local _budget_id=
  local _json="{}"
  local -a _json_alert_rule=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _id=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -i  | --id )
        shift
        _id="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # itterate budgets
  for budget in $( oci.budgets.budget.list --profile ${_profile} --id ${_id} | ${cmd_jq} -c '.[]' ); do
   
    # get budget id
    _budget_id=$( ${cmd_echo} ${budget} | ${cmd_jq} -r '.id' )
    
      # itterate alert-rules
      for alert_rule in $( oci budgets alert-rule list --budget-id ${_budget_id} --profile ${_profile} | ${cmd_jq} -c '.data[]' ); do

        # add alert-rule array
        _json_alert_rule[${_count_alert_rule}]=${alert_rule}
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
        
        # add budget to alert-rule array
        _json_alert_rule[${_count_alert_rule}]=$( json.set --json ${_json_alert_rule[${_count_alert_rule}]} --key .budget --value "${budget}" )
        [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
      
        (( _count_alert_rule++ ))
      done

    (( _count_budget++ ))
  done
  
  # build json list form _json_console_history array
  _json=$( ${cmd_echo} "${_json_alert_rule[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}