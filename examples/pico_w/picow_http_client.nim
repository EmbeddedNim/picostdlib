import std/uri
import std/json
import std/strutils
import picostdlib
import picostdlib/[
  pico/cyw43_arch,
  lib/httpclient
]

const WIFI_SSID {.strdefine.} = ""
const WIFI_PASSWORD {.strdefine.} = ""

const HTTP_URL {.strdefine.} = "https://worldtimeapi.org/api/ip"


proc runHttpClientTest() =
  var client: HttpClient

  let httpBegin = client.begin(HTTP_URL)
  if not httpBegin:
    echo "error creating http client!!"
    return

  echo "http client ok!"

  if client.get() > 0:
    echo "get request ok"
    let data = client.getString()
    echo "data: ", data
  else:
    echo "empty response"

  client.finish()

  echo "closed"
  sleepMs(100)

proc httpClientExample*() =
  if cyw43ArchInit() != PicoErrorNone:
    echo "Wifi init failed!"
    return

  echo "Wifi init successful!"

  Cyw43WlGpioLedPin.put(High)

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

  Cyw43WlGpioLedPin.put(Low)

  echo "ip: ", cyw43State.netif[0].ipAddr, " mask: ", cyw43State.netif[0].netmask, " gateway: ", cyw43State.netif[0].gw
  echo "hostname: ", cast[cstring](cyw43State.netif[0].hostname)

  runHttpClientTest()

  cyw43ArchDeinit()


when isMainModule:
  discard stdioUsbInit()
  blockUntilUsbConnected()

  httpClientExample()

  while true: tightLoopContents()
