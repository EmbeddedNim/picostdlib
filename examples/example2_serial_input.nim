## Raspberry Pi Pico SDK for Nim, 
## Example 2 - Serial Input
## 
## This program reads from the USB serial port, and based on the input, turns
## an external LED on/off. This allows you to type commands on a serial monitor
## on your computer and have code execute on the microcontroller.

import picostdlib/[gpio, time, stdio]

stdioInitAll() # VERY IMPORTANT, must be done to use the USB serial port

let led = DefaultLedPin # define GPIO pin that LED will be connected to
led.init() # initialize the GPIO pin
led.setDir(Out) # set the direction of the GPIO pin, sending signal to LED

sleep(600) # required due to SDK bugs, out of our control

print("Light Switch! Type 1 for ON and 0 for OFF: ")


## Using a while loop like this is called **polling**, and it is not very 
## efficient. Imagine you are expecting a visitor, so you go and check the front 
## door every minute. Eventually, you will meet your vistor at the door, but 
## most of the time your probably won't. The more stuff you put in the loop, the 
## longer it will take to go check the door each time. **Interrupts** are like 
## adding a doorbell to your home, freeing you to do other things. you can also 
## use **multicore** methods, which is like hiring a doorman to monitor the door.

while true: 
  
  print("input [1/0]: ")
  
  var input = readChar(stdin)

  if input != '1' and input != '0': # check if input is one of two valid options
    print("\n    Invalid Input! try again ... \n")
    print("    Type 1 for ON and 0 for OFF: \n")

  elif input == '1': # if it is the first option, turn on LED
    led.put(High)
    print("\n    LED switched ON\n")
  
  else: # we can only get to this point if input = '0' , so no need to test
    led.put(Low)
    print("\n    LED switched OFF\n")
