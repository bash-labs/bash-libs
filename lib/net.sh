# lib/net.sh
# Network helper module
#

[[ -n "${NET_SH_LOADED:-}" ]] && return
readonly NET_SH_LOADED=1

#
# Address / port utils
#

net::is_ip() {
  local ip="$1"

  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

net::is_port() {
  local port="$1"

  [[ "$port" =~ ^[0-9]+$ ]] && (( port > 0 && port < 65536 ))
}

#
# Interface utils
#

net::if_exists() {
  ip link show "$1" >/dev/null 2>&1
}

net::if_up() {
  local iface="$1"

  net::if_exists "$iface" || return 1
  ip link set "$iface" up
}

net::if_down() {
  local iface="$1"

  net::if_exists "$iface" || return 1
  ip link set "$iface" down
}

net::if_addr() {
  local iface="$1"

  net::if_exists "$iface" || return 1
  ip -o -4 addr show "$iface" | awk '{print $4}'
}

#
# Connectivity checks
#

net::ping() {
  local host="$1"
  local timeout="${2:-1}"

  ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
}

net::port_open() {
  local host="$1"
  local port="$2"
  local timeout="${3:-1}"

  net::is_port "$port" || return 1
  nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1
}

#
# HTTP client
#

net::http_get() {
  local url="$1"

  curl -fsSL "$url"
}

net::http_post() {
  local url="$1"
  local data="$2"

  curl -fsSL -X POST --data "$data" "$url"
}

########################################
# TCP server
########################################
# Простейший однопоточный TCP-сервер.
# Обработчик получает stdin/stdout сокета.
#
# net::tcp_server <port> <handler_fn>
#
# handler_fn() {
#   read request
#   echo "response"
# }
########################################
net::tcp_server() {
  local port="$1"
  local handler="$2"

  net::is_port "$port" || return 1
  [[ "$(type -t "$handler")" == "function" ]] || return 1

  while true; do
    nc -l -p "$port" -q 1 | "$handler"
  done
}

########################################
# HTTP server (minimal)
########################################
# Примитивный HTTP/1.0 сервер поверх nc
#
# net::http_server <port> <handler_fn>
#
# handler_fn <method> <path>
########################################
net::http_server() {
  local port="$1"
  local handler="$2"

  net::is_port "$port" || return 1
  [[ "$(type -t "$handler")" == "function" ]] || return 1

  while true; do
    nc -l -p "$port" -q 1 | {
      read -r method path _

      {
        printf 'HTTP/1.0 200 OK\r\n'
        printf 'Content-Type: text/plain\r\n'
        printf '\r\n'
        "$handler" "$method" "$path"
      }
    }
  done
}
