import picostdlib

proc callback(pin: Gpio, events: set[GpioIrqLevel]) {.cdecl.} =
  echo $pin & ": " & $events

stdioInitAll()

echo "Hello GPIO IRQ"

gpioSetIrqEnabledWithCallback(Gpio(2), {EdgeRise, EdgeFall}, true, callback)

while true: tightLoopContents()
