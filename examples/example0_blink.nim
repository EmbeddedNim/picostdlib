## Raspberry Pi Pico SDK for Nim, 
## Example 0 - Blink
## 
## This is the "Hello, World!" of micro-controllers, simply flash the onboard 
## LED on th Raspberry Pi Pico, no need for external components.

import picostdlib/[gpio, time]

DefaultLedPin.init() # Onboard LED available on the original Raspberry Pi Pico
DefaultLedPin.setDir(Out)

while true:
  DefaultLedPin.put(High)
  sleep(500) # do nothing for 500 milliseconds (0.5 seconds)
  DefaultLedPin.put(Low)
  sleep(500)
