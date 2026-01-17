# lib/const.sh
# Default constants module
#
[[ -n "${CONST_SH_LOADED:-}" ]] && return
readonly CONST_SH_LOADED=1

readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1

readonly STDIN=0
readonly STDOUT=1
readonly STDERR=2
