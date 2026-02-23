# lib/jsonq.sh
# Упрощённый доступ к JSON через jq
#
# Функции:
#  jsonq::get <src> <query>
#  jsonq::set <src> <path> <value>
#

[[ -n "${JSONQ_SH_LOADED:-}" ]] && return
readonly JSONQ_SH_LOADED=1

# Принимает JSON-строку или путь к файлу, выводит содержимое в stdout
__jsonq_input() {
  local src="$1"

  if [[ -f "$src" ]]; then
    cat "$src"
  else
    printf '%s' "$src"
  fi
}

########################################
# Извлечь значение из JSON
# Arguments:
#   src   - JSON строка или путь к файлу
#   query - jq выражение (напр. ".name", ".users[0].email")
# Returns:
#   Результат запроса без обрамляющих кавычек (raw)
########################################
jsonq::get() {
  local src="$1"
  local query="$2"

  __jsonq_input "$src" | jq -r "$query"
}

########################################
# Установить значение в JSON
# Тип значения определяется автоматически:
#   - валидный JSON (число, bool, null, объект, массив, "строка") → как есть
#   - всё остальное → строка
# Arguments:
#   src   - JSON строка или путь к файлу
#   path  - jq путь (напр. ".name", ".users[0].age")
#   value - значение: 42, true, null, "text", {"k":1}, или просто hello
# Returns:
#   Модифицированный JSON (stdout)
########################################
jsonq::set() {
  local src="$1"
  local path="$2"
  local value="$3"

  if printf '%s' "$value" | jq -e . >/dev/null 2>&1; then
    __jsonq_input "$src" | jq --argjson v "$value" "$path = \$v"
  else
    __jsonq_input "$src" | jq --arg v "$value" "$path = \$v"
  fi
}
