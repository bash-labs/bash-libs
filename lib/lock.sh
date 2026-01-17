# lib/lock.sh
# Защита от race condition
#
# Функции:
#  lock::acquire <name>
#  lock::release <name>
#  lock::with <name> <fn>
#

[[ -n "${LOCK_SH_LOADED:-}" ]] && return
readonly LOCK_SH_LOADED=1
