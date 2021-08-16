import picostdlib
import picostdlib/[adc, gpio]

stdioInitAll()
print("ADC Example, measuring GPIO25\n")
adcInit()
let adcPin = 26.Gpio
adcPin.init()
Adc26.selectInput
while true:
  let res = adcRead()
  print("Raw value: " & $res & " voltage: " & $(res.float * ThreePointThreeConv) & "\n")
  sleep(500)
