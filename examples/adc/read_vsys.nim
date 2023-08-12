import std/math
import std/strformat

import picostdlib
import picostdlib/hardware/adc
import picostdlib/pico

when defined(picoCyw43Supported):
  import picostdlib/pico/cyw43_arch

const picoPowerSampleCount = 10

type
  PowerSource = enum
    BusPowered = "Bus", BatteryPowered = "Battery"

proc powerSourceBattery(): bool =
  when defined(picoCyw43Supported):
    return Cyw43WlGpioVbusPin.get() == Low
  else:
    VbusPin.setFunction(Sio)
    return VbusPin.get() == Low

proc powerSourceVoltage(): float32 =
  when defined(picoCyw43Supported):
    cyw43ThreadEnter()
    defer: cyw43ThreadExit()
    # Make sure cyw43 is awake
    discard Cyw43WlGpioVbusPin.get()

  if not adcInitialized():
    adcInit()

  VsysPin.initAdc()
  VsysPin.toAdcInput().selectInput()
  adcFifoSetup(en = true, dreqEn = false, dreqThresh = 0, errInFifo = false, byteShift = false)

  var vsys: uint32 = 0
  withAdcRunLock:
    var ignoreCount = picoPowerSampleCount
    while not adcFifoIsEmpty() or (dec(ignoreCount); ignoreCount) > 0:
      discard adcFifoGetBlocking()

    for i in 0 ..< picoPowerSampleCount:
      let v = adcFifoGetBlocking()
      vsys += v

  adcFifoDrain()

  vsys = (vsys div picoPowerSampleCount) * 3

  # calculate voltage
  return float32(vsys) * ThreePointThreeConv

proc main() =
  stdioInitAll()

  adcInit()
  adcSetTempSensorEnabled(true)

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
    var voltage = floor(powerSourceVoltage() * 100) / 100
    var percent_str = ""
    if batteryStatus:
      const min_battery_volts = 3.0f
      const max_battery_volts = 4.2f
      let percent_val = int ((voltage - min_battery_volts) / (max_battery_volts - min_battery_volts)) * 100
      percent_str = &" {percent_val}%"

    let tempC = 27 - (AdcTemp.read().float32 * ThreePointThreeConv - 0.706f) / 0.001721

    DefaultLedPin.put(Low)

    echo &"Power source: {batteryStatus.PowerSource}, {voltage:.2f}V{percent_str}, temp {tempC:.1f} °C"

    sleepMs(1000)
  
  when defined(picoCyw43Supported):
    cyw43ArchDeinit()

main()
