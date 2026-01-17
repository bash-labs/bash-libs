# lib/fs.sh
# Filesystem helper module
#

[[ -n "${FS_SH_LOADED:-}" ]] && return
readonly FS_SH_LOADED=1

#
# Path checks
#

fs::exists() {
  [[ -e "$1" ]]
}

fs::is_file() {
  [[ -f "$1" ]]
}

fs::is_dir() {
  [[ -d "$1" ]]
}

#
# Path utils
#

fs::abs() {
  local path="$1"

  if command -v realpath >/dev/null 2>&1; then
    realpath "$path"
    return
  fi
}

fs::dirname() {
  dirname "$1"
}

fs::basename() {
  basename "$1"
}

#
# directory ops
#

fs::mkdir_p() {
  mkdir -p "$1"
}

#
# File IO
#

fs::read() {
  local path="$1"

  fs::is_file $path || return 1

  cat "$path"
}

fs::write() {
  local path="$1"
  shift

  printf '%s' "$*" >"$path"
}

fs::append() {
  local path="$1"
  shift

  printf '%s' "$*" >>"$path"
}

fs::tmpfile() {
  local prefix="${1:-tmp}"
  local dir="${TMPDIR:-/tmp}"

  mktemp "$dir/${prefix}.XXXXXX"
}

#
# File metadata
#

fs::size() {
  local path="$1"

  fs::exists "$path" || return 1

  stat -c '%s' "$path"
}

fs::mtime() {
  local path="$1"

  fs::exists "$path" || return 1

  stat -c '%Y' "$path"
}

#
# File ops
#

fs::copy() {
  local src="$1"
  local dst="$2"

  cp -a "$src" "$dst"
}

fs::move() {
  local src="$1"
  local dst="$2"

  mv "$src" "$dst"
}

fs::remove() {
  local path="$1"

  rm -rf "$path"
}

#
# Directory listing
#

fs::ls() {
  local path="$1"

  fs::is_dir "$path" || return 1

  ls -A "$path"
}

fs::walk() {
  local root="$1"
  local handler="$2"

  fs::is_dir "$root" || return 1
  [[ "$(type -t "$handler")" == "function" ]] || return 1

  local path
  while IFS= read -r -d '' path; do
    "$handler" "$path"
  done < <(find "$root" -mindepth 1 -print0)
}

fs::hash() {
  local path="$1"
  local algo="${2:-sha256}"

  [[ -f "$path" ]] || return 1

  case "$algo" in
    sha256)
      sha256sum "$path" | awk '{print $1}'
      ;;
    sha1)
      sha1sum "$path" | awk '{print $1}'
      ;;
    md5)
      md5sum "$path" | awk '{print $1}'
      ;;
    *)
      return 1
      ;;
  esac
}

fs::hash() {
  local path="$1"
  local algo="${2:-sha256}"

  fs::is_file || return 1

  case "$algo" in
    sha256)
      sha256sum "$path" | awk '{print $1}'
      ;;
    sha1)
      sha1sum "$path" | awk '{print $1}'
      ;;
    md5)
      md5sum "$path" | awk '{print $1}'
      ;;
    *)
      return 1
      ;;
  esac
}
