
import std/[strutils]

import picostdlib/[
  pico/stdio,
  pico/platform,
  pico/cyw43_arch
]

discard stdioUsbInit()
blockUntilUsbConnected()

proc scanResult(env: pointer; res: ptr Cyw43EvScanResultT): cint {.noconv.} =
  if not res.isNil:
    let ssid = cast[cstring](res.ssid[0].addr)
    echo(
      "ssid: ", ssid,
      " rssi: ", res.rssi,
      " chan: ", res.channel,
      " mac: ", res.bssid[0].toHex, ":", res.bssid[1].toHex, ":", res.bssid[2].toHex, ":", res.bssid[3].toHex, ":", res.bssid[4].toHex, ":", res.bssid[5].toHex,
      " sec: ", res.authMode
    )
  return 0

if cyw43ArchInit() != ErrorNone:
  echo "Wifi init failed!"
else:
  echo "Wifi init successful!"
  cyw43ArchGpioPut(CYW43_WL_GPIO_LED_PIN, true)

  cyw43ArchEnableStaMode()

  var scanOptions: Cyw43WifiScanOptionsT
  let err = cyw43WifiScan(cyw43State.addr, scanOptions.addr, nil, scanResult)
  if err == 0:
    echo "Performing wifi scan"
    while cyw43WifiScanActive(cyw43State.addr): tightLoopContents()
  else:
    echo "Failed to start wifi scan: ", err

  echo "Finished scan!"

  cyw43ArchGpioPut(CYW43_WL_GPIO_LED_PIN, false)

  cyw43ArchDeinit()

while true: tightLoopContents()
