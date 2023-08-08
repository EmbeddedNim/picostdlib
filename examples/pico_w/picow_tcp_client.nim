import std/uri
import std/json
import std/strutils
import picostdlib
import picostdlib/[
  pico/cyw43_arch,
  lib/wifi/tcpcontext
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
  var client: TcpContext
  client.init(tls = TCP_USE_TLS, sniHostname = HOSTNAME)

  # var ip: IpAddrT
  # discard ipaddrAton(TCP_IP, ip.addr)
  # echo "Resolving hostname ", HOSTNAME
  # if not getHostByName(HOSTNAME, ip):
  #   echo "unable to resolve dns name ", HOSTNAME
  #   return
  # let connected = client.connect(ip, Port(TCP_PORT))

  echo "connecting to ", HOSTNAME, ":", TCP_PORT
  let connected = client.connect(HOSTNAME, Port(TCP_PORT))
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

  var ssid = WIFI_SSID
  if ssid == "":
    stdout.write("Enter Wifi SSID: ")
    stdout.flushFile()
    ssid = stdinReadLine()

  var password = WIFI_PASSWORD
  if password == "":
    stdout.write("Enter Wifi password: ")
    stdout.flushFile()
    password = stdinReadLine()

  echo "Connecting to Wifi ", ssid

  let err = cyw43ArchWifiConnectTimeoutMs(ssid.cstring, password.cstring, AuthWpa2AesPsk, 30000)
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
