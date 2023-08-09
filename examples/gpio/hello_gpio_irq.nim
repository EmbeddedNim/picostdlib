import picostdlib

proc callback(pin: Gpio, events: set[GpioIrqLevel]) {.cdecl.} =
  echo $pin & ": " & $events

stdioInitAll()

echo "Hello GPIO IRQ"

Gpio(2).setIrqEnabledWithCallback({EdgeRise, EdgeFall}, true, callback)

while true: tightLoopContents()
