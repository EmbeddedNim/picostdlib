import std/times, std/volatile
import picostdlib
import picostdlib/[
  hardware/rtc,
  pico/cyw43_arch,
  lib/lwip_apps
]


const WIFI_SSID {.strdefine.} = ""
const WIFI_PASSWORD {.strdefine.} = ""
const NTP_SERVER {.strdefine.} = "pool.ntp.org"

var sntpTimeSynced = false
var syncedTimeAt = nilTime

proc sntpSetSystemTime(sec: uint32) {.exportc: "__sntp_set_system_time", cdecl.} =
  syncedTimeAt = getAbsoluteTime()
  var dt: types.Datetime
  let t = fromUnix(sec.int64).utc()
  dt.year = t.year.int16
  dt.month = t.month.int8
  dt.day = t.monthday.int8
  dt.dotw = int8(getDayOfWeek(t.monthday, t.month, t.year).ord + 1) mod 7
  dt.hour = t.hour
  dt.min = t.minute
  dt.sec = t.second
  if rtcSetDatetime(dt.addr):
    volatileStore(sntpTimeSynced.addr, true)

proc runNtpTest() =
  rtcInit()

  sntp_setservername(0, NTP_SERVER.cstring)

  sntp_setoperatingmode(SntpOPmodePoll)
  sntp_init()

  while not volatileLoad(sntpTimeSynced.addr):
    tightLoopContents()
    sleepMs(10)

  var dt: types.Datetime
  if rtcGetDatetime(dt.addr):
    echo "Current RTC time: ", dt
  else:
    echo "No datetime set!"

  # we are done
  sntp_stop()

proc ntpClientExample*() =
  if cyw43ArchInit() != PicoErrorNone:
    echo "Wifi init failed!"
    return

  echo "Wifi init successful!"

  cyw43ArchGpioPut(Cyw43WlGpioLedPin, High)

  cyw43ArchEnableStaMode()

  static:
    assert(WIFI_SSID != "", "Need to define WIFI_SSID with a value")

  let err = cyw43ArchWifiConnectTimeoutMs(WIFI_SSID, WIFI_PASSWORD, AuthWpa2AesPsk, 30000)
  if err != PicoErrorNone:
    echo "Failed to connect! Error: ", $err
  else:
    echo "Connected"

  cyw43ArchGpioPut(Cyw43WlGpioLedPin, Low)

  echo "ip: ", cyw43State.netif[0].ipAddr, " mask: ", cyw43State.netif[0].netmask, " gateway: ", cyw43State.netif[0].gw
  echo "hostname: ", cast[cstring](cyw43State.netif[0].hostname)

  runNtpTest()

  cyw43ArchDeinit()


when isMainModule:
  discard stdioUsbInit()
  blockUntilUsbConnected()

  ntpClientExample()

  while true: tightLoopContents()
