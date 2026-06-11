# lib/arg.sh
# Декларативный парсинг "$@"
#
# Функции:
#  arg::spec <type> <canonical> [aliases...]   объявить опцию (до arg::parse)
#  arg::parse "$@"                             разобрать аргументы
#  arg::has <key>                              наличие флага/опции
#  arg::get <key> [default]                    значение value-опции
#  arg::list <key>                             значения list-опции (по строке)
#  arg::rest                                   позиционные аргументы
#  arg::reset                                  сбросить spec и состояние
#
# Типы опций (arg::spec):
#  flag    булев флаг без значения
#  value   опция с одним значением (--key value, --key=value, -k value)
#  list    опция со списком значений (--key v1 v2 v3 ...), сбор до след. "-..."
#
# Поддерживаемые форматы:
#  --flag, -f              булевый флаг
#  --key value             длинный ключ + значение  (требует spec value/list)
#  --key=value             длинный ключ + значение  (через =, spec не обязателен)
#  -k value                короткий ключ + значение (следующий не начинается с -)
#  -многобукв value        короткий многобуквенный ключ + значение (требует spec)
#  --                      всё после — позиционные аргументы
#
# Без объявленных через arg::spec опций поведение полностью совместимо
# со старым (эвристическим) разбором.
#

[[ -n "${ARG_SH_LOADED:-}" ]] && return
readonly ARG_SH_LOADED=1

declare -A __arg_flags=()
declare -A __arg_values=()
declare -a __arg_rest=()

# Таблицы спецификации опций
declare -A __arg_spec=()    # canonical -> flag|value|list
declare -A __arg_canon=()   # любое написание -> canonical
declare -A __arg_lists=()   # canonical -> значения, склеенные \n

########################################
# Объявить опцию для разбора
# Arguments:
#   type      - flag | value | list
#   canonical - каноническое имя (напр. --domains)
#   aliases   - дополнительные написания (напр. -d), отображаются на canonical
# Returns:
#   0 при успехе, 1 при неизвестном типе
########################################
arg::spec() {
  local type="$1"
  shift

  case "$type" in
    flag|value|list) ;;
    *) return 1 ;;
  esac

  local canonical="$1"
  local name
  for name in "$@"; do
    __arg_canon["$name"]="$canonical"
  done

  __arg_spec["$canonical"]="$type"
}

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
  __arg_lists=()

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

    # --key=value (с резолвом в каноническое имя, если объявлено)
    if [[ "$arg" == --*=* ]]; then
      local k="${arg%%=*}"
      local c="${__arg_canon[$k]:-$k}"
      __arg_values["$c"]="${arg#*=}"
      i=$(( i + 1 ))
      continue
    fi

    # Объявленная опция (по canonical или alias)
    local canon="${__arg_canon[$arg]:-}"
    if [[ -n "$canon" ]]; then
      case "${__arg_spec[$canon]}" in
        flag)
          __arg_flags["$canon"]=1
          i=$(( i + 1 ))
        ;;

        value)
          local ni=$(( i + 1 ))
          if [[ $ni -lt $n ]]; then
            __arg_values["$canon"]="${args[$ni]}"
            i=$(( i + 2 ))
          else
            __arg_flags["$canon"]=1
            i=$(( i + 1 ))
          fi
        ;;

        list)
          local vals=()
          local ni=$(( i + 1 ))
          while [[ $ni -lt $n && "${args[$ni]}" != -* ]]; do
            vals+=("${args[$ni]}")
            ni=$(( ni + 1 ))
          done
          local IFS=$'\n'
          __arg_lists["$canon"]="${vals[*]}"
          i=$ni
        ;;
      esac
      continue
    fi

    # ---- фоллбэк: исходное эвристическое поведение ----

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
# Проверить наличие флага или опции
# Arguments:
#   key - имя флага/опции (canonical или alias)
# Returns:
#   0 если присутствует, 1 если нет
########################################
arg::has() {
  local c="${__arg_canon[$1]:-$1}"
  [[ -n "${__arg_flags[$c]:-}" || -n "${__arg_values[$c]:-}" || -n "${__arg_lists[$c]:-}" ]]
}

########################################
# Получить значение value-опции
# Arguments:
#   key     - имя опции (canonical или alias)
#   default - значение по умолчанию (опционально)
# Returns:
#   Значение или default (stdout)
########################################
arg::get() {
  local c="${__arg_canon[$1]:-$1}"
  local default="${2:-}"
  echo "${__arg_values[$c]:-$default}"
}

########################################
# Получить значения list-опции
# Arguments:
#   key - имя опции (canonical или alias)
# Returns:
#   По одному значению на строку (stdout); ничего, если опция отсутствует
########################################
arg::list() {
  local c="${__arg_canon[$1]:-$1}"
  [[ -n "${__arg_lists[$c]:-}" ]] || return 0
  printf '%s\n' "${__arg_lists[$c]}"
}

########################################
# Получить позиционные аргументы
# Returns:
#   По одному аргументу на строку (stdout)
########################################
arg::rest() {
  printf '%s\n' "${__arg_rest[@]+"${__arg_rest[@]}"}"
}

########################################
# Сбросить объявленные опции и состояние
# Returns:
#   None
########################################
arg::reset() {
  __arg_flags=()
  __arg_values=()
  __arg_rest=()
  __arg_lists=()
  __arg_spec=()
  __arg_canon=()
}
