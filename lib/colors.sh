# lib/colors.sh
# Default colors module
#

[[ -n "${COLORS_SH_LOADED:-}" ]] && return
readonly COLORS_SH_LOADED=1

readonly C_DEF='\033[0m'
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_MAGENTA='\033[35m'
