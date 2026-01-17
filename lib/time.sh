# lib/time.sh
# Измерения и таймауты без date-магии
#
# Функции:
#  time::now
#  time::sleep_ms
#  time::measure <fn>
#  time::timeout <sec> <cmd…>
#

[[ -n "${TIME_SH_LOADED:-}" ]] && return
readonly TIME_SH_LOADED=1
