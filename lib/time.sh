# lib/time.sh
# Измерения и таймауты без date-магии
#
# Функции:
#  time::now
#  time::sleep_ms <ms>
#  time::measure <fn> [args…]
#

[[ -n "${TIME_SH_LOADED:-}" ]] && return
readonly TIME_SH_LOADED=1

########################################
# Текущее время в миллисекундах (Unix timestamp)
# Returns:
#   Целое число мс с начала эпохи
########################################
time::now() {
  date +%s%3N
}

########################################
# Спать заданное количество миллисекунд
# Arguments:
#   ms - время в миллисекундах
# Returns:
#   None
########################################
time::sleep_ms() {
  local ms="$1"
  local sec frac

  sec=$(( ms / 1000 ))
  frac=$(( ms % 1000 ))

  sleep "${sec}.$(printf '%03d' "$frac")"
}

########################################
# Измерить время выполнения функции
# Arguments:
#   fn   - имя функции
#   args - аргументы функции (опционально)
# Returns:
#   Время выполнения в мс (stdout)
########################################
time::measure() {
  local fn="$1"
  shift

  local start end
  start=$(time::now)
  "$fn" "$@"
  end=$(time::now)

  echo $(( end - start ))
}

