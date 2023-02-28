import picostdlib/[pico/stdio, hardware/adc, hardware/gpio, pico/time]

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
