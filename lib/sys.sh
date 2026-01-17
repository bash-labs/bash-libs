# lib/sys.sh
# Унификация доступа к системе
#
# Функции:
#  sys::os
#  sys::arch
#  sys::uptime
#  sys::mem
#  sys::cpu_cores
#

[[ -n "${SYS_SH_LOADED:-}" ]] && return
readonly SYS_SH_LOADED=1
