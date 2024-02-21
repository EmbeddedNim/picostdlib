import std/strformat
import ../pico/cyw43_arch
import ./dns

template debugv(text: string) = echo text

type
  Port* = distinct uint16

  SocketType* = enum
    SOCK_STREAM = 1 # Sequenced, reliable, connection-based byte streams
    SOCK_DGRAM = 2 # Connectionless, unreliable datagrams of fixed maximum length.
    SOCK_RAW = 3 # Raw protocol interface.

  AddressFamily* = enum
    AF_UNSPEC =  0 # Unspecified.
    AF_INET   =  2 # IP protocol family.
    AF_INET6  = 10 # IP version 6.

  SocketState = enum
    STATE_NEW = 0
    STATE_LISTENING = 1
    STATE_CONNECTING = 2
    STATE_CONNECTED = 3
    STATE_PEER_CLOSED = 4
    STATE_ACTIVE_UDP = 5

  Socket*[kind: static[SocketType]] = object
    when kind == SOCK_STREAM:
      pcb: ptr AltcpPcb
    elif kind == SOCK_DGRAM:
      pcb: ptr UdpPcb
    elif kind == SOCK_RAW:
      pcb: ptr RawPcb
    else:
      pcb: void
    timeoutMs: int
    blocking: bool
    rxBuf: ptr Pbuf
    rxBufOffset: uint16

    connectPending: bool
    sendWaiting: bool
    opStartTime: AbsoluteTime
    domain: AddressFamily
    state: SocketState
    err: ErrEnumT

  SocketAny* = Socket[SOCK_STREAM] | Socket[SOCK_DGRAM] | Socket[SOCK_RAW]


proc `==`*(a, b: Port): bool {.borrow.}
proc `$`*(p: Port): string {.borrow.}

func getBasePcb*(self: Socket[SOCK_STREAM]): ptr TcpPcb =
  if not self.pcb.isNil:
    if not self.pcb.state.isNil:
      return cast[ptr TcpPcb](self.pcb.state)
func getBasePcb*(self: Socket[SOCK_DGRAM]): ptr UdpPcb {.inline.} =
  return self.pcb
func getBasePcb*(self: Socket[SOCK_RAW]): ptr RawPcb {.inline.} =
  return self.pcb

proc notifyError(self: var Socket[SOCK_STREAM]) =
  if self.connectPending or self.sendWaiting:
    # resume connect or _write_from_source
    self.sendWaiting = false
    self.connectPending = false
    # self.connected = false
    # esp_schedule();

proc discardReceived(self: var SocketAny) =
  withLwipLock:
    debugv(&":discard {(if not self.rxBuf.isNil: self.rxBuf.totLen else: 0)}")
    if self.rxBuf == nil:
      return
    let totLen = self.rxBuf.totLen
    discard pbufFree(self.rxBuf)
    self.rxBuf = nil
    self.rxBufOffset = 0
    if self.pcb != nil:
      when self.kind == SOCK_STREAM:
        altcpRecved(self.pcb, totLen)

proc abort*(self: var Socket[SOCK_STREAM]): ErrEnumT =
  withLwipLock:
    if self.pcb != nil:
      # self.discardReceived()
      debugv(":abort")
      altcpArg(self.pcb, nil)
      altcpSent(self.pcb, nil)
      altcpRecv(self.pcb, nil)
      altcpErr(self.pcb, nil)
      altcpPoll(self.pcb, nil, 0)
      altcpAbort(self.pcb)
      self.pcb = nil
  return ErrAbrt

proc close*(self: var Socket[SOCK_STREAM]): ErrEnumT =
  result = ErrOk
  if self.pcb != nil:
    self.discardReceived()
    withLwipLock:
      debugv(":close")
      altcpArg(self.pcb, nil)
      altcpSent(self.pcb, nil)
      altcpRecv(self.pcb, nil)
      altcpErr(self.pcb, nil)
      altcpPoll(self.pcb, nil, 0)
      result = altcpClose(self.pcb).ErrEnumT
      if result != ErrOk:
        debugv(&":close err {result}")
        altcpAbort(self.pcb)
        result = ErrAbrt
    self.pcb = nil

proc availableForWrite*(self: Socket[SOCK_STREAM]): uint =
  return if self.pcb != nil: altcpSndbuf(self.pcb) else: 0

proc setNoDelay*(self: var Socket[SOCK_STREAM]; nodelay: bool) =
  if self.pcb == nil:
    return
  withLwipLock:
    if nodelay:
      altcpNagleDisable(self.pcb)
    else:
      altcpNagleEnable(self.pcb)

proc getNoDelay*(self: Socket[SOCK_STREAM]): bool =
  if self.pcb == nil:
    return false
  return altcpNagleDisabled(self.pcb).bool

func setTimeout*(self: var SocketAny; timeoutMs: Natural) =
  self.timeoutMs = timeoutMs

func getTimeout*(self: SocketAny): Natural =
  return self.timeoutMs

func getRemoteAddress*(self: SocketAny): ptr IpAddrT =
  if self.pcb.isNil:
    return nil
  return self.getBasePcb().remote_ip.addr

func getRemotePort*(self: SocketAny): Port =
  if self.pcb.isNil:
    return 0.Port
  return self.getBasePcb().remote_port.Port

func getLocalAddress*(self: SocketAny): ptr IpAddrT =
  if self.pcb.isNil:
    return nil
  return self.getBasePcb().local_ip.addr

func getLocalPort*(self: SocketAny): Port =
  if self.pcb.isNil:
    return 0.Port
  return self.getBasePcb().local_port.Port

func available*(self: SocketAny): uint16 =
  if self.rxBuf.isNil:
    return 0
  return self.rxBuf.totLen - self.rxBufOffset

func connected*(self: Socket[SOCK_STREAM]): bool =
  return not self.pcb.isNil and (self.state == STATE_CONNECTED or self.available() > 0)

proc consume(self: var Socket[SOCK_STREAM]; size: uint16; buf: ptr char = nil): int =
  if self.rxBuf == nil:
    let timedOut = cyw43WaitCondition(self.timeoutMs, self.state != STATE_CONNECTED or self.rxBuf != nil)
    if timedOut:
      return -1

    if self.state == STATE_PEER_CLOSED:
      if self.available() == 0:
        return 0
    elif self.state != STATE_CONNECTED:
      return -1

  withLwipLock:
    assert(self.rxBuf != nil)
    assert(self.pcb != nil)

    var remaining = self.rxBuf.len - self.rxBufOffset
    let size = min(size, remaining)

    remaining -= size

    if remaining == 0:
      if self.rxBuf.next != nil:
        debugv(&":consume next {size}, {self.rxBuf.len}, {self.rxBuf.totLen}")
        let next = self.rxBuf.next
        pbufRef(self.rxBuf.next)
        discard pbufFree(self.rxBuf)
        self.rxBuf = next
        self.rxBufOffset = 0
      else:
        debugv(&":consume emptied {size}, {self.rxBuf.totLen}")
        discard pbufFree(self.rxBuf)
        self.rxBuf = nil
        self.rxBufOffset = 0
    else:
      debugv(&":consume {size}, {self.rxBuf.len}, {self.rxBuf.totLen}")
      if buf != nil:
        let copySize = pbufCopyPartial(self.rxBuf, buf, size, self.rxBufOffset)
        debugv(&":copy {copySize}")
        assert(size == copySize)
      self.rxBufOffset += size

    altcpRecved(self.pcb, size)
    return size.int

# lwip callback wrappers
proc errCb(self: var Socket[SOCK_STREAM]; err: ErrEnumT) =
  debugv(&":error {err}") # {cast[uint32](self.datasource):#X}")
  withLwipLock:
    altcpArg(self.pcb, nil)
    altcpSent(self.pcb, nil)
    altcpRecv(self.pcb, nil)
    altcpErr(self.pcb, nil)
  self.pcb = nil
  self.notifyError()

proc pollCb(self: var Socket[SOCK_STREAM]; pcb: ptr AltcpPcb): ErrEnumT =
  assert(pcb == self.pcb)
  debugv(":poll - timed out")
  # self.writeSomeFromCb()
  return self.close()

proc connectCb(self: var Socket[SOCK_STREAM]; pcb: ptr AltcpPcb; err: ErrEnumT): ErrEnumT =
  assert(pcb == self.pcb)
  debugv(&":connect-cb {err}")
  self.err = err
  if self.connectPending:
    # resume connect
    self.connectPending = false
  return ErrOk

proc sentCb(self: var Socket[SOCK_STREAM]; pcb: ptr AltcpPcb; len: uint16): ErrEnumT =
  assert(pcb == self.pcb)
  debugv(&":sent {len}")
  # self.writeSomeFromCb()
  return ErrOk

proc recvCb(self: var Socket[SOCK_STREAM]; pcb: ptr AltcpPcb; pb: ptr Pbuf; err: ErrEnumT): ErrEnumT =
  assert(pcb == self.pcb)
  debugv(":recv")
  if pb == nil:
    # connection closed by peer
    debugv(&":remote closed pb={(cast[uint](self.rxBuf))} sz={(if self.rxBuf.isNil: -1 else: self.rxBuf.totLen.int)}")
    self.notifyError()
    if self.rxBuf != nil and self.rxBuf.totLen > 0:
      # there is still something to read
      return ErrOk
    else:
      # nothing in receive buffer,
      # peer closed = nothing can be written:
      # closing in the legacy way
      discard self.abort()
      return ErrAbrt
  if self.rxBuf != nil:
    debugv(&":recv {pb.totLen} ({self.rxBuf.totLen} total)")
    pbufCat(self.rxBuf, pb)
    # altcpRecved is called in consume()
  else:
    debugv(&":recv {pb.totLen} (new)")
    self.rxBuf = pb
    self.rxBufOffset = 0
  return ErrOk

# lwip callbacks low level
proc altcpErrCb(arg: pointer; err: ErrT) {.cdecl.} =
  assert(arg != nil)
  cast[ptr Socket[SOCK_STREAM]](arg)[].errCb(cast[ErrEnumT](err))

proc altcpPollCb(arg: pointer; pcb: ptr AltcpPcb): ErrT {.cdecl.} =
  assert(arg != nil)
  return cast[ptr Socket[SOCK_STREAM]](arg)[].pollCb(pcb).ErrT

proc altcpConnectCb(arg: pointer; pcb: ptr AltcpPcb; err: ErrT): ErrT {.cdecl.} =
  assert(arg != nil)
  return cast[ptr Socket[SOCK_STREAM]](arg)[].connectCb(pcb, err.ErrEnumT).ErrT

proc altcpSentCb(arg: pointer; pcb: ptr AltcpPcb; len: uint16): ErrT {.cdecl.} =
  assert(arg != nil)
  return cast[ptr Socket[SOCK_STREAM]](arg)[].sentCb(pcb, len).ErrT

proc altcpRecvCb(arg: pointer; pcb: ptr AltcpPcb; pb: ptr Pbuf; err: ErrT): ErrT {.cdecl.} =
  assert(arg != nil)
  return cast[ptr Socket[SOCK_STREAM]](arg)[].recvCb(pcb, pb, err.ErrEnumT).ErrT

proc write*(self: var Socket[SOCK_STREAM]; data: string|openArray[char]): int =
  if self.pcb == nil or data.len > uint16.high.int:
    return -1
  if data.len == 0:
    return 0
  withLwipLock:
    let sndBuf = altcpSndbuf(self.pcb)
    if sndBuf == 0:
      return 0
    assert(data.len.uint16 <= sndBuf)
    let err = altcpWrite(self.pcb, data[0].unsafeAddr, data.len.uint16, 0).ErrEnumT
    if err != ErrOk:
      debugv(&":writefail {err}")
      return -1
    return 0

proc read*(self: var Socket[SOCK_STREAM]; length: Natural; buf: ptr char): int =
  if length > uint16.high.int:
    return -1
  return self.consume(length.uint16, buf)

proc connect*(self: var Socket[SOCK_STREAM]; ipaddr: IpAddrT; port: Port): bool =
  # note: not using `const ip_addr_t* addr` because
  # - `ip6_addr_assign_zone()` below modifies `*addr`
  # - caller's parameter `WiFiClient::connect` is a local copy
  when defined(lwipIpv6):
    # Set zone so that link local addresses use the default interface
    if ip_Is_V6(ipaddr) and ip6AddrLacksZone(ip2Ip6(ipaddr), ip6Unknown):
      ip6AddrAssignZone(ip2Ip6(ipaddr), ip6Unknown, netifDefault)

  if self.pcb.isNil or self.connected:
    return false

  withLwipLock:
    altcpSetprio(self.pcb, TCP_PRIO_MIN)
    altcpArg(self.pcb, self.addr)
    altcpRecv(self.pcb, altcpRecvCb)
    altcpSent(self.pcb, altcpSentCb)
    altcpErr(self.pcb, altcpErrCb)
    altcpPoll(self.pcb, altcpPollCb, uint8(self.timeoutMs div 500))

  self.connectPending = true
  self.opStartTime = getAbsoluteTime()

  # withLwipLock:
  debugv(&":connect {ipaddr.unsafeAddr} {port}")
  self.err = altcpConnect(self.pcb, ipaddr.unsafeAddr, port.uint16, altcpConnectCb).ErrEnumT
  if self.err != ErrOk:
    return false

  # will resume on timeout or when _connected or _notify_error fires
  # give scheduled functions a chance to run (e.g. Ethernet uses recurrent)
  pollDelay(self.timeoutMs, self.connectPending)
  let timeout = self.connectPending
  self.connectPending = false

  if self.pcb == nil:
    debugv(":connect aborted")
    return false

  if timeout:
    debugv(":connect time out")
    discard self.abort()
    return false

  if self.err != ErrOk:
    debugv(&":connect error {self.err}")
    discard self.abort()
    return false

  self.state = STATE_CONNECTED

  return true

proc connect*(self: var Socket[SOCK_STREAM]; hostname: string; port: Port; secure: bool = false; sniHostname: string = hostname): bool =
  if self.pcb == nil:
    return false

  if secure:
    self.pcb = altcpTlsWrap(altcpTlsCreateConfigClient(nil, 0), self.pcb)
    assert(self.pcb != nil)
    let sslCtx = cast[ptr MbedtlsSslContext](altcpTlsContext(self.pcb))
    # Set SNI
    if sniHostname != "" and mbedtlsSslSetHostname(sslCtx, sniHostname) != 0:
      debugv(":mbedtls set hostname failed!")
      return false

  var remoteAddr: IpAddrT
  if getHostByName(hostname, remoteAddr, self.timeoutMs):
    return self.connect(remoteAddr, port)
  return false


proc init*(self: var Socket[SOCK_STREAM]; timeoutMs: Natural = 30_000; blocking: bool = false) =
  assert(self.pcb == nil)
  self.rxBuf = nil
  self.rxBufOffset = 0
  self.timeoutMs = timeoutMs
  self.blocking = blocking

  var allocator: AltcpAllocatorT
  allocator.alloc = altcpTcpAlloc
  allocator.arg = nil
  self.pcb = altcpNewIpType(allocator.addr, IPADDR_TYPE_ANY.ord)
  assert(self.pcb != nil)
