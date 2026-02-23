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
kv::parse() {
  local arg
  local key
  local value

  for arg in "$@"; do
    key="${arg%%=*}"
    value="${arg#*=}"

    printf '%s\t%s\n' "${key}" "${value}"
  done
}

########################################
# Построение JSON из аргументов
# Arguments:
#   args - аргументы вида "key=value"
# Returns:
#   JSON строка
########################################
kv::build_json() {
  local json="{"
  local first=1

  while IFS=$'\t' read -r key value; do
    if [[ $first -eq 1 ]]; then
      first=0
    else
      json+=","
    fi

    # Проверка, является ли значение числом
    if [[ "$value" =~ ^[0-9]+$ ]]; then
      json+="\"$key\":$value"
    else
      json+="\"$key\":\"$value\""
    fi
  done < <(kv::parse "$@")

  json+="}"
  echo "$json"
}
