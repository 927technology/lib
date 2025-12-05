# . ${_lib_root}/927/ops/restart.f
# . ${_lib_root}/927/ops/config/new.f
# . ${_lib_root}/927/ops/config/pull/secretservice.f

. ${_lib_root}/927/ops/create/clouds.f
. ${_lib_root}/927/ops/create/commands.f
. ${_lib_root}/927/ops/create/contactgroups.f
. ${_lib_root}/927/ops/create/contacts.f
. ${_lib_root}/927/ops/create/hostgroups.f
. ${_lib_root}/927/ops/create/hosts.f
. ${_lib_root}/927/ops/create/mod-gearman-module.f
. ${_lib_root}/927/ops/create/routers.f
. ${_lib_root}/927/ops/create/servers.f
. ${_lib_root}/927/ops/create/servicegroups.f
. ${_lib_root}/927/ops/create/services.f
. ${_lib_root}/927/ops/create/servicedependencies.f
. ${_lib_root}/927/ops/create/serviceescalations.f
. ${_lib_root}/927/ops/create/timeperiods.f

. ${_lib_root}/927/ops/config/compare.f
. ${_lib_root}/927/ops/config/fetch.f
. ${_lib_root}/927/ops/config/validate.f

# . ${_lib_root}/927/ops/restart.f
# . ${_lib_root}/927/ops/secretservice/git/${SECRET_PROVIDER}/secretservice.f
. ${_lib_root}/927/ops/start/manager.f
. ${_lib_root}/927/ops/start/jobserver.f
. ${_lib_root}/927/ops/start/jobworker.f
. ${_lib_root}/927/ops/start/web.f
# . ${_lib_root}/927/ops/create/workerserver.f
# . ${_lib_root}/927/ops/running/get.f
# . ${_lib_root}/927/ops/validate.f