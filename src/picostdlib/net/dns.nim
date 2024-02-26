import ../lib/lwip
import ../pico/cyw43_arch

when not defined(release) or defined(debugDns):
  template debugv(text: string) = echo text
else:
  template debugv(text: string) = discard

type
  DnsState = object
    ipaddr: IpAddrT
    running: bool
    err: bool

  DnsCbState = object
    callback: DnsCallback

  DnsCallback* = proc(hostname: string; ipaddr: ptr IpAddrT) {.raises: [].}

proc dnsGethostbynameCb(hostname: cstring; ipaddr: ptr IpAddrT; arg: pointer) {.cdecl.} =
  let state = cast[ref DnsCbState](arg)
  state.callback($hostname, ipaddr)
  GC_unref(state)

proc getHostByName*(hostname: string; callback: DnsCallback; timeoutMs: Natural = 5000): bool =
  var err: ErrEnumT
  var ipaddrIn: IpAddrT

  withLwipLock:
    var state = new(DnsCbState)
    state.callback = callback

    err = dnsGethostbyname(hostname.cstring, ipaddrIn.addr, dnsGethostbynameCb, cast[pointer](state)).ErrEnumT

    if err == ErrInprogress:
      GC_ref(state)
      return true
    elif err != ErrOk:
      debugv(":dns err=" & $err & " " & hostname)
      return false
    debugv(":dns found " & $ipaddrIn)
    callback(hostname, ipaddrIn.addr)
    return true

proc getHostByName*(hostname: string; ipaddr: var IpAddrT; timeoutMs: Natural = 5000): bool =
  var state = DnsState(running: true)
  let ok = getHostByName(hostname, proc (hostnameOut: string; ipaddrOut: ptr IpAddrT) {.raises: [].} =
    if ipaddrOut != nil:
      state.ipaddr = ipaddrOut[]
    state.err = ipaddrOut.isNil
    state.running = false
  , timeoutMs = timeoutMs)
  if not ok:
    return false
  if not state.running:
    if state.err:
      return false
    ipaddr = state.ipaddr
    return true

  pollDelay(timeoutMs, state.running)

  if state.running:
    return false

  ipaddr = state.ipaddr
  return true
