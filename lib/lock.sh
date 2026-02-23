# lib/lock.sh
# Защита от race condition
#
# Функции:
#  lock::acquire <name> [timeout]
#  lock::release <name>
#  lock::with <name> <fn> [args…]
#

[[ -n "${LOCK_SH_LOADED:-}" ]] && return
readonly LOCK_SH_LOADED=1

declare -A __lock_fds=()

########################################
# Захватить лок по имени
# Arguments:
#   name    - имя лока
#   timeout - таймаут в секундах (0 = без ожидания, по умолчанию — блокирующий)
# Returns:
#   0 при успехе, 1 если лок занят (при timeout)
########################################
lock::acquire() {
  local name="$1"
  local timeout="${2:-}"
  local lockfile="${TMPDIR:-/tmp}/.lock_${name}"

  local fd
  exec {fd}>"$lockfile"

  if [[ -n "$timeout" ]]; then
    flock -w "$timeout" "$fd" || { exec {fd}>&-; return 1; }
  else
    flock "$fd"
  fi

  __lock_fds["$name"]="$fd"
}

########################################
# Освободить лок
# Arguments:
#   name - имя лока
# Returns:
#   0 при успехе, 1 если лок не был захвачен
########################################
lock::release() {
  local name="$1"
  local fd="${__lock_fds[$name]:-}"

  [[ -z "$fd" ]] && return 1

  flock -u "$fd"
  exec {fd}>&-
  unset "__lock_fds[$name]"

  rm -f "${TMPDIR:-/tmp}/.lock_${name}"
}

########################################
# Выполнить функцию под локом
# Лок автоматически освобождается после завершения.
# Arguments:
#   name - имя лока
#   fn   - имя функции
#   args - аргументы функции (опционально)
# Returns:
#   Код завершения fn
########################################
lock::with() {
  local name="$1"
  local fn="$2"
  shift 2

  lock::acquire "$name" || return 1

  local rc=0
  "$fn" "$@" || rc=$?

  lock::release "$name"
  return $rc
}
