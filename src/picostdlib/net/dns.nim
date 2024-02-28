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

  DnsCallback* = proc(hostname: string; ipaddr: ptr IpAddrT)

var dnsCbSlots: array[DNS_MAX_REQUESTS, DnsCallback]

proc getSlot(): int =
  for i, slot in dnsCbSlots:
    if slot == nil:
      return i
  return -1

proc dnsGethostbynameCb(hostname: cstring; ipaddr: ptr IpAddrT; arg: pointer) {.cdecl.} =
  let slotIndex = cast[int](arg)
  var callback = dnsCbSlots[slotIndex] #cast[ref DnsCbState](arg)
  if callback == nil: return
  callback($hostname, ipaddr)
  reset(callback)
  callback = nil
  #GC_unref(state)

proc getHostByName*(hostname: string; callback: DnsCallback; timeoutMs: Natural = 5000): bool =
  var err: ErrEnumT
  var ipaddrIn: IpAddrT

  withLwipLock:
    var slotIndex = getSlot()
    if slotIndex < 0:
      debugv(":dns callback count limit reached")
      return false
    #var state = new(DnsCbState)
    #state.callback = callback

    err = dnsGethostbyname(hostname.cstring, ipaddrIn.addr, dnsGethostbynameCb, cast[pointer](slotIndex)).ErrEnumT

    if err == ErrInprogress:
      dnsCbSlots[slotIndex] = callback
      #GC_ref(state)
      return true
    elif err != ErrOk:
      debugv(":dns err=" & $err & " " & hostname)
      return false
    debugv(":dns found " & $ipaddrIn)
    callback(hostname, ipaddrIn.addr)
    return true

proc getHostByName*(hostname: string; ipaddr: var IpAddrT; timeoutMs: Natural = 5000): bool =
  var state = DnsState(running: true)
  let ok = getHostByName(hostname, proc (hostnameOut: string; ipaddrOut: ptr IpAddrT) =
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
