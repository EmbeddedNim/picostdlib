import std/strformat

import picostdlib
import picostdlib/hardware/adc
import picostdlib/power

when defined(picoCyw43Supported):
  import picostdlib/pico/cyw43_arch

type
  PowerSource = enum
    BusPowered = "Bus"
    BatteryPowered = "Battery"

proc main() =
  stdioInitAll()

  adcInit()

  when defined(picoCyw43Supported):
    if cyw43ArchInit() != PicoOk:
      echo "failed to initialize cyw43"
      return
  else:
    DefaultLedPin.init()
    DefaultLedPin.setDir(Out)

  while true:
    DefaultLedPin.put(High)

    let batteryStatus = powerSourceBattery()
    var voltage = powerSourceVoltage()

    var percent_str = ""
    if batteryStatus:
      const min_battery_volts = 3.0f
      const max_battery_volts = 4.2f
      let percent_val = int ((voltage - min_battery_volts) / (max_battery_volts - min_battery_volts)) * 100
      percent_str = &", {percent_val} %"

    let tempC = adcReadTemp()

    DefaultLedPin.put(Low)

    echo &"Power source: {batteryStatus.PowerSource}, {voltage:.3f} V{percent_str}, temp {tempC:.2f} °C"

    sleepMs(1000)
  
  when defined(picoCyw43Supported):
    cyw43ArchDeinit()

main()
