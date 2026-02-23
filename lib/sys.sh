# lib/sys.sh
# Унификация доступа к системе
#
# Функции:
#  sys::os
#  sys::arch
#  sys::uptime
#  sys::mem
#  sys::cpu_cores
#

[[ -n "${SYS_SH_LOADED:-}" ]] && return
readonly SYS_SH_LOADED=1

########################################
# Название операционной системы
# Returns:
#   Строка: linux | darwin | windows | unknown
########################################
sys::os() {
  local raw
  raw="$(uname -s 2>/dev/null)"

  case "${raw,,}" in
    linux*)   echo "linux"   ;;
    darwin*)  echo "darwin"  ;;
    mingw*|cygwin*|msys*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

########################################
# Архитектура процессора
# Returns:
#   Строка: x86_64 | arm64 | arm | i386 | unknown
########################################
sys::arch() {
  local raw
  raw="$(uname -m 2>/dev/null)"

  case "$raw" in
    x86_64|amd64)          echo "x86_64" ;;
    aarch64|arm64)         echo "arm64"  ;;
    armv*|arm)             echo "arm"    ;;
    i386|i486|i586|i686)   echo "i386"   ;;
    *)                     echo "unknown" ;;
  esac
}

########################################
# Аптайм системы в секундах
# Returns:
#   Целое число секунд
########################################
sys::uptime() {
  if [[ -r /proc/uptime ]]; then
    awk '{printf "%d\n", $1}' /proc/uptime
    return
  fi

  # macOS fallback
  if command -v sysctl >/dev/null 2>&1; then
    local boot now
    boot=$(sysctl -n kern.boottime 2>/dev/null | awk '{print $4}' | tr -d ',')
    now=$(date +%s)
    echo $(( now - boot ))
    return
  fi

  return 1
}

########################################
# Информация об оперативной памяти (кБ)
# Arguments:
#   field - total | free | available (по умолчанию total)
# Returns:
#   Число в кБ
########################################
sys::mem() {
  local field="${1:-total}"

  if [[ -r /proc/meminfo ]]; then
    case "$field" in
      total)     awk '/^MemTotal:/     {print $2}' /proc/meminfo ;;
      free)      awk '/^MemFree:/      {print $2}' /proc/meminfo ;;
      available) awk '/^MemAvailable:/ {print $2}' /proc/meminfo ;;
      *)         return 1 ;;
    esac
    return
  fi

  # macOS fallback (только total)
  if command -v sysctl >/dev/null 2>&1; then
    case "$field" in
      total) sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024)}' ;;
      *)     return 1 ;;
    esac
    return
  fi

  return 1
}

########################################
# Количество логических ядер CPU
# Returns:
#   Целое число
########################################
sys::cpu_cores() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
    return
  fi

  if [[ -r /proc/cpuinfo ]]; then
    grep -c '^processor' /proc/cpuinfo
    return
  fi

  # macOS fallback
  if command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.logicalcpu 2>/dev/null
    return
  fi

  return 1
}
