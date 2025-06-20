. ${_lib_root}/927/ops/restart.f
. ${_lib_root}/927/ops/config/new.f
# . ${_lib_root}/927/ops/config/pull/secretservice.f

. ${_lib_root}/927/ops/create/commands.f
. ${_lib_root}/927/ops/create/contactgroups.f
. ${_lib_root}/927/ops/create/contacts.f
. ${_lib_root}/927/ops/create/hostgroups.f
. ${_lib_root}/927/ops/create/hosts.f
. ${_lib_root}/927/ops/create/jobserver.f
. ${_lib_root}/927/ops/create/servicegroups.f
. ${_lib_root}/927/ops/create/services.f
. ${_lib_root}/927/ops/create/servicedependencies.f
. ${_lib_root}/927/ops/create/serviceescalations.f
. ${_lib_root}/927/ops/create/timeperiods.f
. ${_lib_root}/927/ops/create/workerserver.f

. ${_lib_root}/927/ops/restart.f
. ${_lib_root}/927/ops/secretservice/git/${SECRET_PROVIDER}/secretservice.f
. ${_lib_root}/927/ops/start/manager.f
. ${_lib_root}/927/ops/start/web.f
. ${_lib_root}/927/ops/running/get.f
. ${_lib_root}/927/ops/validate.f