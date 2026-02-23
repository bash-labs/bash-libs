# lib/arg.sh
# Декларативный парсинг "$@"
#
# Функции:
#  arg::parse "$@"
#  arg::has <flag>
#  arg::get <key> [default]
#  arg::rest
#
# Поддерживаемые форматы:
#  --flag, -f              булевый флаг
#  --key=value             длинный ключ + значение (только через =)
#  -k value                короткий ключ + значение (следующий аргумент не начинается с -)
#  --                      всё после — позиционные аргументы
#

[[ -n "${ARG_SH_LOADED:-}" ]] && return
readonly ARG_SH_LOADED=1

declare -A __arg_flags=()
declare -A __arg_values=()
declare -a __arg_rest=()

########################################
# Распарсить аргументы командной строки
# Arguments:
#   "$@" - аргументы для разбора
# Returns:
#   None (заполняет внутренние таблицы)
########################################
arg::parse() {
  __arg_flags=()
  __arg_values=()
  __arg_rest=()

  local args=("$@")
  local n=${#args[@]}
  local i=0
  local past_sep=0

  while [[ $i -lt $n ]]; do
    local arg="${args[$i]}"

    if [[ $past_sep -eq 1 ]]; then
      __arg_rest+=("$arg")
      i=$(( i + 1 ))
      continue
    fi

    # Разделитель --
    if [[ "$arg" == "--" ]]; then
      past_sep=1
      i=$(( i + 1 ))
      continue
    fi

    # --key=value
    if [[ "$arg" == --*=* ]]; then
      __arg_values["${arg%%=*}"]="${arg#*=}"
      i=$(( i + 1 ))
      continue
    fi

    # --flag  (значение только через =, уже обработано выше)
    if [[ "$arg" == --* ]]; then
      __arg_flags["$arg"]=1
      i=$(( i + 1 ))
      continue
    fi

    # -f или -k value  (только однобуквенные)
    if [[ "$arg" == -? ]]; then
      local ni=$(( i + 1 ))
      local next="${args[$ni]:-}"
      if [[ $ni -lt $n && "$next" != -* ]]; then
        __arg_values["$arg"]="$next"
        i=$(( i + 2 ))
      else
        __arg_flags["$arg"]=1
        i=$(( i + 1 ))
      fi
      continue
    fi

    # Позиционный аргумент
    __arg_rest+=("$arg")
    i=$(( i + 1 ))
  done
}

########################################
# Проверить наличие флага
# Arguments:
#   flag - имя флага (напр. --verbose, -v)
# Returns:
#   0 если флаг присутствует, 1 если нет
########################################
arg::has() {
  [[ -n "${__arg_flags[$1]:-}" ]]
}

########################################
# Получить значение ключа
# Arguments:
#   key     - имя ключа (напр. --output, -o)
#   default - значение по умолчанию (опционально)
# Returns:
#   Значение или default (stdout)
########################################
arg::get() {
  local key="$1"
  local default="${2:-}"
  echo "${__arg_values[$key]:-$default}"
}

########################################
# Получить позиционные аргументы
# Returns:
#   По одному аргументу на строку (stdout)
########################################
arg::rest() {
  printf '%s\n' "${__arg_rest[@]+"${__arg_rest[@]}"}"
}
