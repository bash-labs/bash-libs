# lib/log.sh
# Logger module
#

[[ -n "${LOG_SH_LOADED:-}" ]] && return
readonly LOG_SH_LOADED=1

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/kv.sh"

#
# Module ENV
#
declare -A __log_env

__log_env[LEVEL]=2
__log_env[FD_STDERR]=2
__log_env[FD_STDOUT]=1

__level_to_num() {
  case "$1" in
    error)   echo 0 ;;
    warn)    echo 1 ;;
    info)    echo 2 ;;
    verbose) echo 3 ;;
    *)       echo 2 ;;
  esac
}

########################################
# Logger config
# Globals:
# none
# Arguments:
#   level - log level: verbose, info...
#   to - path to save log and disable
#     output to std. 
# Returns:
#   None
########################################
log::cfg() {
  while IFS=$'\t' read -r key value; do
    case "${key}" in
      level)
        __log_env[LEVEL]=$(__level_to_num "${value}")
      ;;

      to)
        if [[ -n "$value:-" ]]; then
          exec 3>>"$value"
          __log_env[FD_STDERR]=3
          __log_env[FD_STDOUT]=3
        fi
      ;;
    esac
  done < <(kv_eq::parse "$@") || return 1
}

__log_colorise() {
  local color="$1"
  shift

  if (( __log_env[FD_STDOUT] > 2 )); then
    printf "$*"
    return 1
  fi

  printf '%s%s%s' "$color" "$*" "$C_DEF"
}

log::error() {
  (( __log_env[LEVEL] < 0 )) && return
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] E> $(__log_colorise ${C_RED} $*)" >&${__log_env[FD_STDERR]}
}

log::warn() {
  (( __log_env[LEVEL] < 1 )) && return
  echo -e \
  "[$(date +'%Y-%m-%dT%H:%M:%S%z')] W> $(__log_colorise ${C_YELLOW} $*)" >&${__log_env[FD_STDOUT]}
}

log::info() {
  (( __log_env[LEVEL] < 2 )) && return
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] I> $(__log_colorise ${C_GREEN} $*)" >&${__log_env[FD_STDOUT]}
}

log::verbose() {
  (( __log_env[LEVEL] < 3 )) && return
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] V> $(__log_colorise ${C_MAGENTA} $*)" >&${__log_env[FD_STDOUT]}
}
