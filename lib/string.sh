# lib/string.sh
# String helper module
#

[[ -n "${STR_SH_LOADED:-}" ]] && return
readonly STR_SH_LOADED=1

########################################
# String split by separator
########################################
# string::split <arr_name> <separator> <str>
########################################
# Globals:
# none
# Arguments:
#   $1 - Array
#   $2 - Separator
#   $3 - String
# Returns:
#   None
########################################
string::split() {
  local arr_name="$1"
  local sep="$2"
  local str="$3"

  declare -n out="$arr_name"

  local IFS="${sep}"
  read -r -a out <<< "${str}" 
}

#
# Trim
#

string::trim() {
  local s="$1"

  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"

  printf '%s\n' "$s"
}

#
# Case conversion
#

string::lower() {
  local s="$1"

  printf '%s\n' "${s,,}"
}

string::upper() {
  local s="$1"

  printf '%s\n' "${s^^}"
}

#
# Prefix / suffix
#

string::startswith() {
  local s="$1"
  local prefix="$2"

  [[ "$s" == "$prefix"* ]]
}

string::endswith() {
  local s="$1"
  local suffix="$2"

  [[ "$s" == *"$suffix" ]]
}

########################################
# Join
########################################
# string::join <arr_name> <separator>
########################################
string::join() {
  local arr_name="$1"
  local sep="$2"

  [[ -n "$arr_name" ]] || return 1
  declare -n arr="$arr_name"

  local out=""
  for item in "${arr[@]}"; do
    if [[ -z "$out" ]]; then
      out="$item"
    else
      out="$out$sep$item"
    fi
  done

  printf '%s\n' "$out"
}

########################################
# Replace
########################################
# string::replace <string> <from> <to>
# replaces all occurrences
########################################
string::replace() {
  local str="$1"
  local from="$2"
  local to="$3"

  [[ -n "$from" ]] || return 1

  printf '%s\n' "${str//"$from"/"$to"}"
}
