import picostdlib
import picostdlib/[gpio]

proc callback(pin: Gpio, events: set[IrqLevel]){.cDecl.} =
  print($pin & ": " & $events & "\n")

stdioInitAll()
print("Hello GPIO IRQ\n")
enableIrqWithCallback(2.Gpio, {IrqLevel.rise, IrqLevel.fall}, true, callback)
while true: discard
