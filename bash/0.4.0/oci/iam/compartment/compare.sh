#curl -s Https://927technology.github.io/ops/infrastructure.json | jq '.hosts.clouds[] | select(.name=="cmurray").tennants[] | select(.name=="cmurray/927").iac[0].compartments
#oci.iam.compartment.list --profile DEFAULT --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq


# for test in $(oci.iam.compartment.list --profile DEFAULT --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq | jq '.[].description') ; do
#   echo ${test}
#   echo
# done


#!/bin/bash
# description
# extras
IFS=$'\n'

# variables
_json_ai=
_json_oci=

# _lib_root=/home/bryan/Desktop/git/lib/bash/0.4.0
_lib_root=~/git/lib/bash/0.4.0

_profile=ops-ms
# _profile=DEFAULT

success=${false}
_url=https://927technology.github.io/ops

# argument variables
_tenancy=cmurray
_tenant=927

# libraries
. ${_lib_root}/oci.l
. ${_lib_root}/json.l
. ${_lib_root}/variables.l
. ${_lib_root}/standard.l

# parse arguments
while [[ ${1} != "" ]]; do
  case ${1} in
    -t | --tenant )
      shift
      _tenant=${1}
    ;;-T | --tenancy )
      shift
      _tenancy=${1}
    ;;
  esac
  shift
done


# main
_json_ai=$(curl -s ${_url}/infrastructure.json | jq -c '.hosts.clouds[] | select(.name=="'${_tenancy}'").tennants[] | select(.name=="'${_tenancy}'/'${_tenant}'").iac[0].compartments')
# _json_ai=$(curl -s Https://927technology.github.io/ops/infrastructure.json | jq -c '.hosts.clouds[] | select(.name=="cmurray").tennants[] | select(.name=="cmurray/927").iac[0].compartments')

_json_oci=$(oci.iam.compartment.list --profile ${_profile} --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq)
# _json_oci=$(oci.iam.compartment.list --profile DEFAULT --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq)

# echo ----ai----------
# echo "${_json_ai}" | jq
# echo ----oci---------
# echo "${_json_oci}" | jq

# for test in $(echo ${_json_ai} | jq -c '.[]') ; do
#   echo ${test} | jq -r '.label'
#   echo
# done

# for test in $(echo ${_json_oci} | jq -c '.[]') ; do
#   echo ${test} | jq -r 'if(."defined-tags"."927-ops".label==null) then empty else . end'
#   echo
# done


# exit

#homework
# created nested for loop for labels starting on line 36 compare the labels for the loop on line 41


for compartment_ai in $(echo ${_json_ai} | jq -c '.[]') ; do
  #echo ${compartment_ai} | jq
  #echo

  # parse variables from _json_ai defining what we are looking at
  name_ai=$(echo ${compartment_ai} | jq -r '.name')
  description_ai=$(echo ${compartment_ai} | jq -r '.description')
  label_ai=$(echo ${compartment_ai} | jq -r '.label')

  # echo name_ai: ${name_ai}
  # echo
  # echo description_ai: ${description_ai}
  # echo
  # echo label_ai: ${label_ai}
  # echo -------ai----------

  for compartment_oci in $(echo ${_json_oci} | jq -c '.[]') ; do
    # echo ${compartment_oci} | jq
    # echo

    # parsing variables from _json_oci defining what we are looking at
    name_oci=$(echo ${compartment_oci} | jq -r '.name')
    description_oci=$(echo ${compartment_oci} | jq -r '.description')
    label_oci=$(echo ${compartment_oci} | jq -r '."defined-tags"."927-ops".label')

    # new check for tenant name
    tenant_oci=$(echo ${compartment_oci} | jq -r '."defined-tags"."927-ops".tenant')


    # echo name_oci: ${name_oci}
    # echo
    # echo description_oci: ${description_oci}
    # echo
    #echo label_oci: ${label_oci}
    #echo -----oci--------

    #echo ${name_ai} ${name_oci}


    # comparing the outputs between json_ai and json_oci variables
    # if successful then output will be 1

    # changed logic to include check for tenant
    # this appends the tenant name to the label for the ai side
    # while TF will concatinate them in .defined-tags.927-ops.label
    if  [[ ${_tenant}/${label_ai} == ${label_oci} ]]; then
      success=${true}
    fi


  done

  echo success: ${label_ai} ${success}

done




# for A in $(echo ${_json_ai} | jq -c '.[]') ; do
#   unset ${_A2}
#   _A2=$(echo ${A} | jq -r '.label')
#   echo "set A:"${_A2}
#   for B in $(echo ${_json_oci} | jq -c '.[]'); do
#     unset ${_B2}
#     #unset ${_B3}
#     #_B3=$(echo ${B} | jq -r '."defined-tags"')
#     #echo ${_B3}
#     _B2=$(echo ${B} | jq -r 'if(."defined-tags"."927-ops".label==null) then empty else . end')
#     echo "set B:" ${_B2}
#   done
# done

# for A in "$(echo ${_json_ai} | jq -c '.[]')" ; do
#   for B in "$(echo ${_json_oci} | jq -c '.[]')" do
#     if [[ "${A}"=="${B}"]]; then
#       ${found}=true
#       break
#     fi
#   done
#   if ! ${found}; then
#     echo "Not Found: ${A}"
#   fi
# done
