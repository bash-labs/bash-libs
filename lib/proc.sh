# lib/proc.sh
# Корректное управление дочерними процессами
#
# Функции:
#  proc::is_running <pid>
#  proc::wait <pid> [timeout]
#  proc::kill_tree <pid> [signal]
#  proc::on_exit <fn>
#  proc::daemonize [logfile]
#

[[ -n "${PROC_SH_LOADED:-}" ]] && return
readonly PROC_SH_LOADED=1

#
# Process checks
#

########################################
# Проверить, запущен ли процесс
# Arguments:
#   pid - идентификатор процесса
# Returns:
#   0 если запущен, 1 если нет
########################################
proc::is_running() {
  local pid="$1"
  kill -0 "$pid" 2>/dev/null
}

#
# Process control
#

########################################
# Ждать завершения процесса
# Arguments:
#   pid     - идентификатор процесса
#   timeout - таймаут в секундах (0 = без ограничений)
# Returns:
#   0 если процесс завершился, 1 при таймауте
########################################
proc::wait() {
  local pid="$1"
  local timeout="${2:-0}"
  local elapsed=0

  while proc::is_running "$pid"; do
    sleep 0.1
    elapsed=$(( elapsed + 1 ))
    if (( timeout > 0 && elapsed >= timeout * 10 )); then
      return 1
    fi
  done
}

########################################
# Убить процесс и всё его дерево
# Arguments:
#   pid    - корень дерева процессов
#   signal - сигнал (по умолчанию TERM)
# Returns:
#   None
########################################
proc::kill_tree() {
  local pid="$1"
  local sig="${2:-TERM}"

  local child
  for child in $(pgrep -P "$pid" 2>/dev/null || true); do
    proc::kill_tree "$child" "$sig"
  done

  kill "-${sig}" "$pid" 2>/dev/null || true
}

#
# Exit handlers
#

declare -a __proc_exit_handlers=()

__proc_run_exit_handlers() {
  local fn
  for fn in "${__proc_exit_handlers[@]+"${__proc_exit_handlers[@]}"}"; do
    "$fn"
  done
}

trap '__proc_run_exit_handlers' EXIT

########################################
# Зарегистрировать функцию-обработчик при выходе
# Arguments:
#   fn - имя функции
# Returns:
#   0 при успехе, 1 если fn не является функцией
########################################
proc::on_exit() {
  local fn="$1"
  [[ "$(type -t "$fn")" == "function" ]] || return 1
  __proc_exit_handlers+=("$fn")
}

#
# Daemonize
#

########################################
# Перевести текущий процесс в фоновый режим
# Перенаправляет stdin/stdout/stderr, отключает от терминала.
# Должна вызываться в начале скрипта.
# Arguments:
#   logfile - файл для вывода (по умолчанию /dev/null)
# Returns:
#   None
########################################
proc::daemonize() {
  local logfile="${1:-/dev/null}"

  [[ "${__PROC_DAEMONIZED:-}" == "1" ]] && return 0
  export __PROC_DAEMONIZED=1

  exec </dev/null >>"$logfile" 2>&1
  disown -a 2>/dev/null || true
}
