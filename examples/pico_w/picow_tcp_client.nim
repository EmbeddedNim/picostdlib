import picostdlib
import picostdlib/[
  pico/cyw43_arch,
  lib/wifi/clientcontext
]

const WIFI_SSID {.strdefine.} = ""
const WIFI_PASSWORD {.strdefine.} = ""

const TCP_HOSTNAME = "worldtimeapi.org"
const TCP_PORT = 80
const HTTP_PATH = "/api/ip"
const HTTP_REQUEST = "GET " & HTTP_PATH & " HTTP/1.1\r\n" &
                     "Host: " & TCP_HOSTNAME & "\r\n" &
                     "Connection: close\r\n" &
                     "\r\n"

proc runTcpClientTest() =
  var client: ClientContext
  var allocator: AltcpAllocatorT
  allocator.alloc = altcpTcpAlloc
  allocator.arg = nil

  let pcb = altcpNew(allocator.addr)
  client.init(pcb)


  var ip: IpAddrT
  # discard ipaddrAton(TCP_IP, ip.addr)
  echo "Resolving hostname ", TCP_HOSTNAME
  if not getHostByName(TCP_HOSTNAME, ip):
    echo "unable to resolve dns name ", TCP_HOSTNAME
    return

  echo "connecting to ", $ip, ":", TCP_PORT
  let connected = client.connect(ip, Port(TCP_PORT))
  if not connected:
    echo "error connecting!!"
    return

  echo "connected!"

  client.stream.write(HTTP_REQUEST)
  # client.stream.flush()

  while not client.hasData():
    tightLoopContents()

  for line in client.stream.lines():
    echo "header: ", line
    if line.len == 0: break

  for line in client.stream.lines():
    echo "body: ", line

  # while client.getSize() > 0:
  #   var resp = newString(100)
  #   echo "read ", client.read(resp), " bytes"
  #   echo resp

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
