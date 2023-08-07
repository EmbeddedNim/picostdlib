import std/uri
import std/json
import std/strutils
import picostdlib
import picostdlib/[
  pico/cyw43_arch,
  lib/wifi/clientcontext
]

const WIFI_SSID {.strdefine.} = ""
const WIFI_PASSWORD {.strdefine.} = ""

const HTTP_URL {.strdefine.} = "https://worldtimeapi.org/api/ip"
const HTTP_URL_PARSED = HTTP_URL.parseUri

const HOSTNAME = HTTP_URL_PARSED.hostname
const TCP_USE_TLS = HTTP_URL_PARSED.scheme.toLower() == "https"
const TCP_PORT = if TCP_USE_TLS: 443 else: 80

const HTTP_PATH = (if HTTP_URL_PARSED.path == "": "/" else: HTTP_URL_PARSED.path) & (if HTTP_URL_PARSED.query != "": "?" & HTTP_URL_PARSED.query else: "")
const HTTP_REQUEST = "GET " & HTTP_PATH & " HTTP/1.1\r\n" &
                     "Host: " & HOSTNAME & "\r\n" &
                     "Connection: close\r\n" &
                     "\r\n"

proc runTcpClientTest() =
  var client: ClientContext

  var ip: IpAddrT
  # discard ipaddrAton(TCP_IP, ip.addr)
  echo "Resolving hostname ", HOSTNAME
  if not getHostByName(HOSTNAME, ip):
    echo "unable to resolve dns name ", HOSTNAME
    return

  var allocator: AltcpAllocatorT
  allocator.alloc = altcpTcpAlloc
  allocator.arg = nil
  var pcb = altcpNewIpType(allocator.addr, IPADDR_TYPE_ANY.ord)

  if TCP_USE_TLS:
    pcb = altcpTlsWrap(altcpTlsCreateConfigClient(nil, 0), pcb)
    let sslCtx = cast[ptr MbedtlsSslContext](altcpTlsContext(pcb))
    ## Set SNI
    if mbedtlsSslSetHostname(sslCtx, HOSTNAME) != 0:
      echo "mbedtls set hostname failed!"

  client.init(pcb)

  echo "connecting to ", $ip, ":", TCP_PORT
  let connected = client.connect(ip, Port(TCP_PORT))
  if not connected:
    echo "error connecting!!"
    return

  echo "connected!"

  echo "write:"
  echo HTTP_REQUEST
  client.stream.write(HTTP_REQUEST)
  client.stream.flush()

  while not client.hasData():
    tightLoopContents()

  var contentType = "text/plain"

  for line in client.stream.lines():
    if line.len == 0: break
    echo "header: ", line
    if line.toLower.startsWith("content-type: application/json"):
      contentType = "application/json"
    elif line.toLower.startsWith("content-type: text/html"):
      contentType = "text/html"

  if contentType == "application/json":
    echo "Parsing JSON body..."
    try:
      let node = parseJson(client.stream)
      echo pretty node
    except JsonParsingError as e:
      echo "Failed to parse JSON! ", e.msg
  # elif contentType == "text/html":
  else:
    echo "Printing HTTP body..."
    # for line in client.stream.lines():
    #   echo "body: ", line
    while not client.stream.atEnd():
      stdout.write(client.stream.readStr(100))
      stdout.flushFile()
    echo ""

  var closed = client.close()
  if closed != ErrOk:
    echo "error closing! ", closed

  echo "closed"
  sleepMs(100)

proc tcpClientExample*() =
  if cyw43ArchInit() != PicoErrorNone:
    echo "Wifi init failed!"
    return

  echo "Wifi init successful!"

  cyw43ArchGpioPut(Cyw43WlGpioLedPin, High)

  cyw43ArchEnableStaMode()

  static:
    assert(WIFI_SSID != "", "Need to define WIFI_SSID with a value")


  sleepMs(100)
  echo "Connecting to Wifi ", WIFI_SSID

  let err = cyw43ArchWifiConnectTimeoutMs(WIFI_SSID, WIFI_PASSWORD, AuthWpa2AesPsk, 30000)
  if err != PicoErrorNone:
    echo "Failed to connect! Error: ", $err
    return
  else:
    echo "Connected"

  cyw43ArchGpioPut(Cyw43WlGpioLedPin, Low)

  echo "ip: ", cyw43State.netif[0].ipAddr, " mask: ", cyw43State.netif[0].netmask, " gateway: ", cyw43State.netif[0].gw
  echo "hostname: ", cast[cstring](cyw43State.netif[0].hostname)

  runTcpClientTest()

  cyw43ArchDeinit()


when isMainModule:
  discard stdioUsbInit()
  blockUntilUsbConnected()

  tcpClientExample()

  while true: tightLoopContents()
