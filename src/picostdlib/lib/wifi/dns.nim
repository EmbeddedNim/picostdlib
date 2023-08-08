import ../../pico/cyw43_arch

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

proc getHostByName*(hostname: string; ipaddr: var IpAddrT; timeoutMs: uint = 5000): bool =
  var state = DnsCb(running: true)
  var err: ErrT
  withLwipLock:
    err = dnsGethostbyname(hostname, ipaddr.addr, dnsFoundCb, state.addr)

  if err == ERR_OK.ErrT:
    return true
  elif err != ERR_INPROGRESS.ErrT:
    # debugv(":dns err=%d\n", err)
    return false
  else:
    pollDelay(timeoutMs, state.running, 10)
    if state.err:
      return false
    ipaddr = state.ipaddr
    return true
