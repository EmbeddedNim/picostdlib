import std/strformat
import picostdlib
import picostdlib/hardware/adc

type
  TempUnit = enum
    C, F

const tempUnit = C

proc readOnboardTemperature(unit: TempUnit): float =
  let adc = adcRead().float * ThreePointThreeConv
  let tempC = 27.0 - (adc - 0.706) / 0.001721
  case unit:
  of C:
    return tempC
  of F:
    return tempC * 9 / 5 + 32

stdioInitAll()

DefaultLedPin.init()
DefaultLedPin.setDir(Out)

adcInit()
adcSetTempSensorEnabled(true)
adcSelectInput(AdcTemp)

while true:
  let temperature = readOnboardTemperature(tempUnit)
  echo &"Onboard temperature = {temperature:.2f} {tempUnit}"
  DefaultLedPin.put(High)
  sleepMs(10)
  DefaultLedPin.put(Low)
  sleepMs(990)
