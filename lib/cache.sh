# lib/cache.sh
# Ускорение повторных вычислений
#
# Функции:
#  cache::get <key>
#  cache::set <key> <value>
#  cache::invalidate <key>
#  cache::ttl <key> <sec>
#

[[ -n "${CACHE_SH_LOADED:-}" ]] && return
readonly CACHE_SH_LOADED=1
