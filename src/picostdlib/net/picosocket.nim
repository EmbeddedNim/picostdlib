import std/macros
import ../lib/lwip
import ./dns
import ../pico/cyw43_arch

{.push raises: [].}

template debugv(text: string) = echo text

macro ptr2var(arg: pointer; T: static[typedesc]; name: untyped) =
  doAssert(name.kind == nnkIdent)
  let namePtr = ident(name.strVal & "ptr")
  return quote do:
    assert(arg != nil)
    let `namePtr` = cast[ptr `T`](`arg`)
    template `name`: var `T` = `namePtr`[]

type
  Port* = distinct uint16

  SocketType* = enum
    SOCK_STREAM = 1 # Sequenced, reliable, connection-based byte streams
    SOCK_DGRAM = 2 # Connectionless, unreliable datagrams of fixed maximum length.
    SOCK_RAW = 3 # Raw protocol interface.

  SocketState* = enum
    STATE_INVALID
    STATE_NEW
    STATE_LISTENING
    STATE_CONNECTING
    STATE_CONNECTED
    STATE_PEER_CLOSED
    STATE_ACTIVE_UDP

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

    sendWaiting: bool
    state: SocketState
    err: ErrEnumT
    written: uint
    acked: uint

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

func getError*(self: SocketAny): ErrEnumT =
  return self.err

func getState*(self: SocketAny): SocketState =
  return self.state

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

proc discardReceived(self: var SocketAny) =
  withLwipLock:
    if self.rxBuf == nil:
      return
    let totLen = self.rxBuf.totLen
    debugv(":discard " & $totLen)
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
      self.state = STATE_PEER_CLOSED
      debugv(":close")
      altcpArg(self.pcb, nil)
      altcpSent(self.pcb, nil)
      altcpRecv(self.pcb, nil)
      altcpErr(self.pcb, nil)
      altcpPoll(self.pcb, nil, 0)
      result = altcpClose(self.pcb).ErrEnumT
      if result != ErrOk:
        debugv(":close err " & $result)
        altcpAbort(self.pcb)
        result = ErrAbrt
      self.pcb = nil

# lwip callbacks
proc altcpErrCb(arg: pointer; err: ErrT) {.cdecl.} =
  ptr2var(arg, Socket[SOCK_STREAM], self)
  let err = cast[ErrEnumT](err)
  debugv(":error " & $err)
  altcpArg(self.pcb, nil)
  altcpSent(self.pcb, nil)
  altcpRecv(self.pcb, nil)
  altcpErr(self.pcb, nil)
  self.err = err
  self.pcb = nil

proc altcpPollCb(arg: pointer; pcb: ptr AltcpPcb): ErrT {.cdecl.} =
  ptr2var(arg, Socket[SOCK_STREAM], self)
  assert(pcb == self.pcb)
  debugv(":poll - timed out")
  return self.close().ErrT

proc altcpClosePollCb(arg: pointer; pcb: ptr AltcpPcb): ErrT {.cdecl.} =
  # Connection has not been cleanly closed so just abort it to free up memory
  debugv(":poll closing")
  altcpPoll(pcb, nil, 0)
  altcpAbort(pcb)
  return ErrOk.ErrT

proc altcpConnectCb(arg: pointer; pcb: ptr AltcpPcb; err: ErrT): ErrT {.cdecl.} =
  ptr2var(arg, Socket[SOCK_STREAM], self)
  let err = cast[ErrEnumT](err)
  assert(pcb == self.pcb)
  debugv(":connect " & $err)
  self.err = err
  self.state = STATE_CONNECTED
  return ErrOk.ErrT

proc altcpSentCb(arg: pointer; pcb: ptr AltcpPcb; len: uint16): ErrT {.cdecl.} =
  ptr2var(arg, Socket[SOCK_STREAM], self)
  assert(pcb == self.pcb)
  debugv(":sent " & $len)
  self.acked += len
  return ErrOk.ErrT

proc altcpRecvCb(arg: pointer; pcb: ptr AltcpPcb; pb: ptr Pbuf; err: ErrT): ErrT {.cdecl.} =
  ptr2var(arg, Socket[SOCK_STREAM], self)
  # let err = cast[ErrEnumT](err)
  assert(pcb == self.pcb)
  debugv(":recv")
  if pb == nil:
    # connection closed by peer
    debugv(":remote closed pb=" & $cast[uint](self.rxBuf) & " sz=" & $(if self.rxBuf.isNil: -1 else: self.rxBuf.totLen.int))
    self.state = STATE_PEER_CLOSED
    if self.rxBuf != nil and self.rxBuf.totLen > 0:
      # there is still something to read
      return ErrOk.ErrT
    else:
      # nothing in receive buffer,
      # peer closed = nothing can be written:
      # closing in the legacy way
      return self.abort().ErrT
  if self.rxBuf != nil:
    debugv(":recv " & $pb.totLen & " (" & $self.rxBuf.totLen & " total)")
    pbufCat(self.rxBuf, pb)
    # altcpRecved is called in consume()
  else:
    debugv(":recv " & $pb.totLen & " (new)")
    self.rxBuf = pb
    self.rxBufOffset = 0
  return ErrOk.ErrT

proc udpRecvCb(arg: pointer; pcb: ptr UdpPcb; pb: ptr Pbuf; ipAddr: ptr IpAddrT; port: uint16) {.cdecl.} =
  ptr2var(arg, Socket[SOCK_DGRAM], self)
  assert(pcb == self.pcb)
  let port = Port(port)
  debugv(":udprecv " & $pb.totLen & " " & $ipAddr & ":" & $port)
  discard pbufFree(pb)

proc rawRecvCb(arg: pointer; pcb: ptr RawPcb; pb: ptr Pbuf; ipAddr: ptr IpAddrT): uint8 {.cdecl.} =
  ptr2var(arg, Socket[SOCK_RAW], self)
  assert(pcb == self.pcb)
  debugv(":rawrecv " & $pb.totLen & " " & $ipAddr)
  discard pbufFree(pb)
  return 1

proc flush*(self: var Socket[SOCK_STREAM]): bool =
  if self.pcb == nil:
    return false
  withLwipLock:
    debugv(":flushing " & $self.written)
    let err = altcpOutput(self.pcb)
    if err != ErrOk.ErrT:
      debugv(":flushfail " & $err)
      return false
    if self.written == 0:
      return true
    let timedOut = cyw43WaitCondition(self.timeoutMs, self.written <= self.acked or self.state != STATE_CONNECTED)
    if timedOut:
      debugv(":flush - timeout")
    else:
      debugv(":flush complete " & $(self.written, self.acked))
      self.acked -= self.written
      self.written = 0
    return not timedOut

proc write*(self: var Socket[SOCK_STREAM]; data: string|openArray[char]): int =
  if self.pcb == nil:
    return -1
  if data.len == 0:
    return 0
  withLwipLock:
    var remaining = data.len
    var err = ErrOk
    var written = 0
    while remaining > 0:
      var available = altcpSndbuf(self.pcb).int
      if remaining <= available:
        debugv(":write final " & $remaining & " " & $available)
        err = altcpWrite(self.pcb, data[written].unsafeAddr, remaining.uint16, TCP_WRITE_FLAG_COPY).ErrEnumT
        written += remaining
        if err != ErrOk:
          debugv(":writefail " & $err)
          return -1
        else:
          self.written += remaining.uint
          return written
      else:
        let chunk = min(available, remaining)
        if chunk == 0:
          if not self.flush():
            return -1
        else:
          debugv(":write chunk " & $chunk & " " & $available)
          err = altcpWrite(self.pcb, data[written].unsafeAddr, chunk.uint16, TCP_WRITE_FLAG_COPY or TCP_WRITE_FLAG_MORE).ErrEnumT
          written += chunk
          remaining -= chunk
          if err != ErrOk:
            debugv(":writefail " & $err)
            return -1
          else:
            self.written += chunk.uint

  return written

proc available*(self: var SocketAny): uint16 =
  if self.rxBuf.isNil:
    return 0
  return self.rxBuf.totLen - self.rxBufOffset

proc connected*(self: var Socket[SOCK_STREAM]): bool =
  return not self.pcb.isNil and (self.state == STATE_CONNECTED or self.available() > 0)

proc read*(self: var Socket[SOCK_STREAM]; size: uint16; buf: ptr char = nil): int =
  debugv(":read " & $size)

  if self.rxBuf == nil:
    let timedOut = cyw43WaitCondition(self.timeoutMs, self.state != STATE_CONNECTED or self.rxBuf != nil)
    if timedOut:
      return -1

    if self.state == STATE_PEER_CLOSED:
      if self.available() == 0:
        return 0
    elif self.state != STATE_CONNECTED:
      return -1
    return 0

  withLwipLock:
    var remaining = self.rxBuf.len - self.rxBufOffset
    let size = min(size, remaining)

    if buf != nil:
      let copySize = pbufCopyPartial(self.rxBuf, buf, size, self.rxBufOffset)
      debugv(":read copy " & $copySize)
      assert(size == copySize)

    remaining -= size

    if remaining == 0:
      if self.rxBuf.next != nil:
        debugv(":read next " & $size & ", " & $self.rxBuf.len & ", " & $self.rxBuf.totLen)
        let next = self.rxBuf.next
        pbufRef(self.rxBuf.next)
        discard pbufFree(self.rxBuf)
        self.rxBuf = next
        self.rxBufOffset = 0
      else:
        debugv(":read emptied " & $size & ", " & $self.rxBuf.len)
        discard pbufFree(self.rxBuf)
        self.rxBuf = nil
        self.rxBufOffset = 0
    else:
      debugv(":read " & $size & ", " & $self.rxBuf.len & ", " & $self.rxBuf.totLen)
      self.rxBufOffset += size

    if self.pcb != nil:
      altcpRecved(self.pcb, size)
    return size.int

proc connect*(self: var Socket[SOCK_STREAM]; ipaddr: IpAddrT; port: Port): bool =
  # note: not using `const ip_addr_t* addr` because
  # - `ip6_addr_assign_zone()` below modifies `*addr`
  # - caller's parameter `WiFiClient::connect` is a local copy
  when lwipIpv6:
    # Set zone so that link local addresses use the default interface
    if ipIsV6(ipaddr.addr) and ip6AddrLacksZone(ip2Ip6(ipaddr.addr), IP6_UNKNOWN):
      ip6AddrAssignZone(ip2Ip6(ipaddr.addr), IP6_UNKNOWN, netifDefault)

  if self.pcb.isNil:
    return false

  if self.state != STATE_NEW:
    return false

  withLwipLock:
    altcpSetprio(self.pcb, TCP_PRIO_MIN)
    altcpArg(self.pcb, self.addr)
    altcpErr(self.pcb, altcpErrCb)
    altcpRecv(self.pcb, altcpRecvCb)
    altcpSent(self.pcb, altcpSentCb)
    altcpPoll(self.pcb, altcpPollCb, uint8(self.timeoutMs div 500))
    self.state = STATE_CONNECTING

    debugv(":connect " & $ipaddr.unsafeAddr & " " & $port)
    self.err = altcpConnect(self.pcb, ipaddr.unsafeAddr, port.uint16, altcpConnectCb).ErrEnumT
    if self.err != ErrOk:
      self.state = STATE_NEW
      return false

  let timedOut = cyw43WaitCondition(self.timeoutMs, self.state != STATE_CONNECTING)

  if self.pcb == nil:
    debugv(":connect aborted")
    return false

  if timedOut:
    debugv(":connect time out")
    discard self.abort()
    return false

  if self.err != ErrOk:
    debugv(":connect error " & $self.err)
    discard self.abort()
    return false

  self.state = STATE_CONNECTED

  return true

proc connect*(self: var Socket[SOCK_DGRAM]; ipaddr: IpAddrT; port: Port): bool =
  assert(self.pcb != nil)
  self.err = udpConnect(self.pcb, ipaddr.unsafeAddr, port.uint16).ErrEnumT
  return self.err == ErrOk

proc connect*(self: var Socket[SOCK_RAW]; ipaddr: IpAddrT; _: Port = Port(0)): bool =
  assert(self.pcb != nil)
  self.err = rawConnect(self.pcb, ipaddr.unsafeAddr).ErrEnumT
  return self.err == ErrOk

proc connect*(self: var SocketAny; host: string; port: Port; secure: bool = false; sniHostname: string = ""): bool =
  ## Connect using ip address or hostname as string
  assert(self.pcb != nil)

  var remoteAddr: IpAddrT
  let isIp = ipAddrAton(host.cstring, remoteAddr.addr).bool

  when self.kind == SOCK_STREAM:
    let sniHostname = if not isIp and sniHostname.len == 0: host else: sniHostname

    if secure:
      self.pcb = altcpTlsWrap(altcpTlsCreateConfigClient(nil, 0), self.pcb)
      assert(self.pcb != nil)
      let sslCtx = cast[ptr MbedtlsSslContext](altcpTlsContext(self.pcb))
      # Set SNI
      if sniHostname != "" and mbedtlsSslSetHostname(sslCtx, sniHostname.cstring) != 0:
        debugv(":mbedtls set hostname failed!")
        return false

  if isIp:
    return self.connect(remoteAddr, port)
  elif getHostByName(host, remoteAddr, self.timeoutMs):
    return self.connect(remoteAddr, port)
  return false

proc connect*(self: var Socket[SOCK_RAW]; host: string): bool {.inline.} =
  # raw sockets have no port
  self.connect(host, Port(0))

proc init*(self: var SocketAny; timeoutMs: Natural; blocking: bool; ipProto: uint8) =
  assert(self.pcb == nil)
  assert(self.state in [STATE_NEW, STATE_PEER_CLOSED])

  self.state = STATE_NEW
  self.timeoutMs = timeoutMs
  self.rxBuf = nil
  self.rxBufOffset = 0
  self.blocking = blocking

  when self.kind == SOCK_STREAM:
    var allocator: AltcpAllocatorT
    allocator.alloc = altcpTcpAlloc
    allocator.arg = nil
    self.pcb = altcpNewIpType(allocator.addr, IPADDR_TYPE_ANY.ord)
    assert(self.pcb != nil)
    altcpArg(self.pcb, self.addr)
    altcpErr(self.pcb, altcpErrCb)
  elif self.kind == SOCK_DGRAM:
    self.pcb = udpNew()
    assert(self.pcb != nil)
    self.state = STATE_ACTIVE_UDP
    udpRecv(self.pcb, udpRecvCb, self.addr)
  elif self.kind == SOCK_RAW:
    self.pcb = rawNew(ipProto)
    assert(self.pcb != nil)
    rawRecv(self.pcb, rawRecvCb, self.addr)

  debugv(":init " & $self.kind)

proc newSocket*(kind: static[SocketType]; timeoutMs: Natural = 30_000; blocking: bool = false; ipProto: uint8 = 0): owned Socket[kind] =
  result = Socket[kind]()
  result.state = STATE_NEW
  result.init(timeoutMs, blocking, ipProto)

proc `=destroy`*(self: Socket[SOCK_STREAM]) =
  withLwipLock:
    if self.pcb != nil:
      altcpArg(self.pcb, nil)
      altcpSent(self.pcb, nil)
      altcpRecv(self.pcb, nil)
      altcpErr(self.pcb, nil)
      if self.pcb.getTcpState != LISTEN:
        altcpPoll(self.pcb, altcpClosePollCb, uint8(self.timeoutMs div 500))
      else:
        altcpPoll(self.pcb, nil, 0)
      # try close with timeout, otherwise abort
      let err = altcpClose(self.pcb).ErrEnumT
      if err != ErrOk:
        debugv(":destroy close err " & $err)
        altcpAbort(self.pcb)
    if self.rxBuf != nil:
      discard pbufFree(self.rxBuf)
  debugv(":destroyed")

proc `=destroy`*(self: Socket[SOCK_DGRAM]) =
  withLwipLock:
    if self.pcb != nil:
      udpRecv(self.pcb, nil, nil)
      udpRemove(self.pcb)
    if self.rxBuf != nil:
      discard pbufFree(self.rxBuf)
  debugv(":destroyed")

proc `=destroy`*(self: Socket[SOCK_RAW]) =
  withLwipLock:
    if self.pcb != nil:
      rawRecv(self.pcb, nil, nil)
      rawRemove(self.pcb)
    if self.rxBuf != nil:
      discard pbufFree(self.rxBuf)
  debugv(":destroyed")

when defined(runtests) or defined(nimcheck):
  block:
    var t = newSocket(SOCK_STREAM)
    discard t.connect("google.com", Port(80))

  block:
    var u = newSocket(SOCK_DGRAM)
    discard u.connect("127.0.0.1", Port(0))

  block:
    var r = newSocket(SOCK_RAW)
    discard r.connect("127.0.0.1")

{.pop.}
