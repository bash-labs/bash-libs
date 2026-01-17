# lib/kv.sh
# Парсинг аргументов
#

[[ -n "${KV_SH_LOADED:-}" ]] && return
readonly KV_SH_LOADED=1

########################################
# Парсинг аргументов разделенных =
# Globals:
# none
# Arguments:
#   arg - text like "name=uriid1"
# Returns:
#   None (printf 2 values divided by \t)
########################################
kv_eq::parse() {
  local arg
  local key
  local value

  for arg in "$@"; do
    key="${arg%%=*}"
    value="${arg#*=}"

    printf '%s\t%s\n' "${key}" "${value}"
  done
}
