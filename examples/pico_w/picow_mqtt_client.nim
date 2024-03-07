import std/uri
import std/strutils
import picostdlib
import picostdlib/[
  pico/cyw43_arch,
  net/mqttclient
]

const WIFI_SSID {.strdefine.} = ""
const WIFI_PASSWORD {.strdefine.} = ""

const MQTT_USER {.strdefine.} = ""
const MQTT_PASS {.strdefine.} = ""

const MQTT_HOST {.strdefine.} = "192.168.1.6"
const MQTT_TOPIC {.strdefine.} = "picow/ds18/temperature"
# const MQTT_USE_TLS = true


proc runMqttClientTest() =
  var client = newMqttClient()
  var ipaddr: IpAddrT

  discard ipAddrAton(MQTT_HOST, ipaddr.addr)

  let clientInfo = MqttConnectClientInfoT(
    client_id: "PicoW",
    client_user: MQTT_USER,
    client_pass: MQTT_PASS,
    tls_config: nil
  )

  echo "connecting to ", MQTT_HOST

  client.setInpubCallback(proc (topic: string; totLen: uint32) =
    echo "got topic " & $topic
  )

  if client.connect(ipaddr.addr, cb = proc (connStatus: MqttConnectionStatusT) =
    echo "connected!"
    echo connStatus

    echo client.subscribe(MQTT_TOPIC, 0, proc (err: ErrEnumT) =
      echo "ok ", $err
    )
  , clientInfo = clientInfo):
    echo "connecting..."
  else:
    echo "failed to connect to mqtt server"

proc mqttClientExample*() =
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

  echo "ip: ", cyw43State.netif[0].ip_addr, " mask: ", cyw43State.netif[0].netmask, " gateway: ", cyw43State.netif[0].gw
  echo "hostname: ", cast[cstring](cyw43State.netif[0].hostname)

  runMqttClientTest()

  # cyw43ArchDeinit()


when isMainModule:
  discard stdioInitAll()

  mqttClientExample()

  while true:
    Cyw43WlGpioLedPin.put(High)
    sleepMs(100)
    Cyw43WlGpioLedPin.put(Low)
    sleepMs(100)
