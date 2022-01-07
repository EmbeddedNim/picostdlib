## Raspberry Pi Pico SDK for Nim, 
## Example 5 - Pulse Width Modulation (PWM)
##
## This program will fade an LED as an example of how to used Pulse Width 
## Modulation (PWM) to simulate a reduction in voltage. In truth, only the 
## average voltage (over time) can be changed, but this technique works to 
## reduce the speed of motors, fans, LEDs, drive piezo's, etc. 

import picostdlib/[gpio, pwm, time, irq]
import std/math

proc handler(){.cDecl.} =
  var
    fade {.global.} = 0
    goingUp {.global.} = true
  
  # clear the interrupt flag that brought us here
  clear(DefaultLedPin.toSliceNum())
  if fade notin 0..255:
    goingUp = not goingUp

  if goingUp:
    inc fade
  else:
    dec fade
  # square the fade value to make the LED's brightness appear more linear
  # note this range matches with the wrap value
  setLevel(DefaultLedPin, uint16(fade * fade))

# tell the LED pin that the PWM is in charge of its value
DefaultLedPin.setFunction(PWM)
# figure out which slice we just connected to the LED pin
let sliceNum = DefaultLedPin.toSliceNum()

# mask our slice's IRQ output into the PWM block's single interrupt line
sliceNum.clear()
sliceNum.setIrqEnabled(true)
# register our interrupt handler
setExclusiveHandler(PwmIrqWrap, handler)
irq.setEnabled(PwmIrqWrap, true)

# get some sensible defaults for the slice configuration. by default, the
# counter is allowed to wrap over its maximum range (0 to 2**16-1)
let config = getDefaultConfig()
# set divider, reduces counter clock to sysclock/this value
setClockDivide(config, 4.0)
# load the configuration into our PWM slice, and set it running.
sliceNum.init(config, true)

# everything after this point happens in the PWM interrupt handler, so we
# can twiddle our thumbs

while true:
  discard
