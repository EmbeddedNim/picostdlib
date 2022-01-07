import picostdlib/[sevensegdisplay, adc, gpio, stdio]

# This module reads the voltage on pin 26 using ADC and outputs the value between 3.15 - 3.3 in hex(0-F) on the
# seven segmented display.

proc setupPins =
  # My pins are gp 0 to 8 for panel
  # Though it goes a, b, c, dp, d, e, g, f
  var i = 0
  for x in SevenSeg:
    SevenSegPins[x] = i.Gpio
    inc i
  let
    gPin = SevenSegPins[f]
  SevenSegPins[f] = SevenSegPins[g]
  SevenSegPins[g] = gPin

stdioInitAll()
setupPins()
initPins()
adcInit()
let adcPin = 26.Gpio
adcPin.init()
Adc26.selectInput

while true:
  let input = (adcRead().float * ThreePointThreeConv)
  print($input & "\n")
  let toDraw = ((input / 3.3f) * 16f).clamp(0, 16).CharacterName
  toDraw.draw
