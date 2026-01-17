# lib/proc.sh
# Корректное управление дочерними процессами
#
# Функции:
#  proc::is_running <pid>
#  proc::wait <pid> [timeout]
#  proc::kill_tree <pid>
#  proc::on_exit <fn>
#  proc::daemonize
#

[[ -n "${PROC_SH_LOADED:-}" ]] && return
readonly PROC_SH_LOADED=1
