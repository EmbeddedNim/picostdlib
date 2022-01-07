## Raspberry Pi Pico SDK for Nim, 
## Example 5 - Multicore Blink Example
## 
## Use the second core of the RP2040 to "do work" and send the result back to 
## the first core so that it may use those values. In this program, the code 
## beyond 'multicoreFifoPopBlocking()' is not executed until a value is provided
## by the secondCoreCode procedure. 
## 
## remember to add 'pico_multicore' to target_linked_libaries line in 
## 'CMakeLists.txt' within the csource folder

import picostdlib/[gpio, time, multicore]

proc secondCoreCode() {.cdecl.} =
  ## this code will run exclusively on the second core (also called core1).
  while true:
    sleep(500)
    multicoreFifoPushBlocking(High.uint32) # convert distinct type 'Value'
    sleep(500)
    multicoreFifoPushBlocking(Low.uint32)


multicoreLaunchCore1(secondCoreCode)
  
const led = DefaultLedPin
led.init()
led.setDir(Out)
  
while true:
  let result = multicoreFifoPopBlocking() # result is a uint32 value
  led.put(result.Value) # convert uint32 to distinct type 'Value'