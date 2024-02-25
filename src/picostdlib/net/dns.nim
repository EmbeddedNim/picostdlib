import ../lib/lwip
import ../pico/cyw43_arch

when not defined(release) or defined(debugDns):
  template debugv(text: string) = echo text
else:
  template debugv(text: string) = discard

type
  DnsCb = object
    ipaddr: IpAddrT
    running: bool
    err: bool

proc dnsFoundCb(hostname: cstring; ipaddr: ptr IpAddrT; arg: pointer) {.cdecl.} =
  let state = cast[ptr DnsCb](arg)
  if not ipaddr.isNil:
    state.ipaddr = ipaddr[]
  else:
    state.err = true
  state.running = false

proc getHostByName*(hostname: string; ipaddr: var IpAddrT; timeoutMs: Natural = 5000): bool =
  var state = DnsCb(running: true)
  var err: ErrEnumT
  withLwipLock:
    err = dnsGethostbyname(hostname.cstring, ipaddr.addr, dnsFoundCb, state.addr).ErrEnumT

  if err != ErrInprogress:
    debugv(":dns err=" & $err & " " & hostname)
    return false
  else:
    pollDelay(timeoutMs, state.running)
    if state.err:
      debugv(":dns not found " & hostname)
      return false
    if state.running:
      debugv(":dns timeout")
      return false
    ipaddr = state.ipaddr
  debugv(":dns found " & $ipaddr)
  return true

