# lib/assert.sh
# fail-fast подход
#
# Функции:
#  assert::true
#  assert::file
#  assert::dir
#  assert::cmd
#  assert::eq, assert::ne
#

[[ -n "${ASSERT_SH_LOADED:-}" ]] && return
readonly ASSERT_SH_LOADED=1
