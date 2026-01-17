# lib/arg.sh
# Декларативный парсинг "$@"
#
# Функции:
#  arg::parse
#  arg::has <flag>
#  arg::get <key> [default]
#  arg::rest
#

[[ -n "${ARG_SH_LOADED:-}" ]] && return
readonly ARG_SH_LOADED=1
