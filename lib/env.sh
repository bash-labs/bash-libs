# lib/env.sh
# Управление окружением и контекстом выполнения
#
# Функции:
#  env::require <VAR>
#  env::default <VAR> <value>
#  env::export_if_empty
#  env::path_prepend
#  env::path_append
#

[[ -n "${ENV_SH_LOADED:-}" ]] && return
readonly ENV_SH_LOADED=1
