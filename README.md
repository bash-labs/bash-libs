# Вспомогательные библиотеки для bash скриптинга

**Декларативный парсинг "$@"**
- [ ] `lib/arg.sh`
  - [ ] `arg::parse`
  - [ ] `arg::has`
  - [ ] `arg::get`
  - [ ] `arg::rest`

**fail-fast подход**
- [ ] `lib/assert.sh`
  - [ ] `assert::true`
  - [ ] `assert::file`
  - [ ] `assert::dir`
  - [ ] `assert::cmd`
  - [ ] `assert::eq`
  - [ ] `assert::ne`

**Ускорение повторных вычислений**
- [ ] `lib/cache.sh`
  - [ ] `cache::get`
  - [ ] `cache::set`
  - [ ] `cache::invalidate`
  - [ ] `cache::ttl`

**Цветовые константы / функции**
- [ ] `lib/colors.sh`

**Системные константы**
- [ ] `lib/const.sh`

**Управление окружением и контекстом выполнения**
- [ ] `lib/env.sh`
  - [ ] `env::require`
  - [ ] `env::default`
  - [ ] `env::export_if_empty`
  - [ ] `env::path_prepend`
  - [ ] `env::path_append`

**Вспомогательный модуль файловой системы**
- [x] `lib/fs.sh`
  - [x] `fs::exists`
  - [x] `fs::is_file`
  - [x] `fs::is_dir`
  - [x] `fs::abs`
  - [x] `fs::dirname`
  - [x] `fs::basename`
  - [x] `fs::mkdir_p`
  - [x] `fs::read`
  - [x] `fs::write`
  - [x] `fs::append`
  - [x] `fs::tmpfile`
  - [x] `fs::size`
  - [x] `fs::mtime`
  - [x] `fs::copy`
  - [x] `fs::move`
  - [x] `fs::remove`
  - [x] `fs::ls`
  - [x] `fs::walk`
  - [x] `fs::hash`
  - [x] `fs::hash`

**Упрощенный доступ к json через jq**
- [ ] `lib/jsonq.sh`
  - [ ] `jsonq::get`
  - [ ] `jsonq::set`

**key value parser (deprecated)**
- [x] `lib/kv.sh`
  - [x] `kv::parse`
  - [x] `kv::build_json`

**Защита от race condition**
- [ ] `lib/lock.sh`
  - [ ] `lock::acquire`
  - [ ] `lock::release`
  - [ ] `lock::with`

**Минималистичнй логгер**
- [x] `lib/log.sh`
  - [x] `log::cfg`
  - [x] `log::error`
  - [x] `log::warn`
  - [x] `log::info`
  - [x] `log::verbose`

**Вспомогательный сетевой модуль**
- [x] `lib/net.sh`
  - [x] `net::is_ip`
  - [x] `net::is_port`
  - [x] `net::if_exists`
  - [x] `net::if_up`
  - [x] `net::if_down`
  - [x] `net::if_addr`
  - [x] `net::ping`
  - [x] `net::port_open`
  - [x] `net::http_get`
  - [x] `net::http_post`
  - [x] `net::tcp_server`
  - [x] `net::http_server`

**Корректное управление дочерними процессами**
- [x] `lib/proc.sh`
  - [x] `proc::is_running`
  - [x] `proc::wait`
  - [x] `proc::kill_tree`
  - [x] `proc::on_exit`
  - [x] `proc::daemonize`

**Вспомогательный модуль для строк**
- [x] `lib/string.sh`
  - [x] `string::split`
  - [x] `string::trim`
  - [x] `string::lower`
  - [x] `string::upper`
  - [x] `string::startswith`
  - [x] `string::endswith`
  - [x] `string::join`
  - [x] `string::replace`

**Унификация доступа к системе**
- [x] `lib/sys.sh`
  - [x] `sys::os`
  - [x] `sys::arch`
  - [x] `sys::uptime`
  - [x] `sys::mem`
  - [x] `sys::cpu_cores`

**Измерения и таймауты без date-магии**
- [ ] `lib/time.sh`
  - [ ] `time::now`
  - [ ] `time::sleep_ms`
  - [ ] `time::measure`
  - [ ] `time::timeout`
