import picostdlib
import picostdlib/hardware/adc

stdioInitAll()

echo "ADC Example, measuring GPIO26"

let adcPin = Gpio(26)

adcInit()
adcGpioInit(adcPin)
adcSelectInput(Adc26)

while true:
  let res = adcRead()
  echo "Raw value: " & $res & " voltage: " & $(res.float * ThreePointThreeConv)
  sleepMs(500)
