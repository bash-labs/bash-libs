# lib/jsonq.sh
# ...
#
# Функции:
# jsonq::get
# jsonq::set
#

[[ -n "${JSONQ_SH_LOADED:-}" ]] && return
readonly JSONQ_SH_LOADED=1
