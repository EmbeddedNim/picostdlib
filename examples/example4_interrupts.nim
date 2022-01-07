## Raspberry Pi Pico SDK for Nim, 
## Example 4 - Interrupts
##
## In this example, we are using a button to trigger an interrupt which will 
## tell the core on the RP2040 to stop what it is doing and run the code inside
## the handler() procedure and then return back to what it was doing. Ideally,
## the code inside the handler() proc would be short and fast.

import picostdlib/[gpio]

let 
  # for this program to work, these pins must be defined BEFORE handler() proc
  led = Gpio.init(5) # another way to intialize a Gpio pin defaults to Out dir
  button = Gpio.init(7)


proc handler(pin: Gpio, events: set[IrqLevel]) {.cDecl.} =
  ## when a rising or falling edge is detected on button, this proc runs.
  ## changes the led high or low, depending on the state of the button
  let state = pin.get()
  if state == Low:
    led.put(High)
  else:
    led.put(Low)

 
# define an interupt event, part of the gpio module
enableIrqWithCallback(button, {IrqLevel.rise, IrqLevel.fall}, true, handler)

# useless loop to keep program running indefinitely
while true:
  discard