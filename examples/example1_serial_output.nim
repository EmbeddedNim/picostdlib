## Raspberry Pi Pico SDK for Nim, 
## Example 1 - Serial Output
## 
## This program outputs "Hello, World!" to the USB serial port. If your Pico is
## plugged into your computer, try using a serial monitor such as minicom on 
## linux machines, or PuTTY on Windows to view its output

import picostdlib/[stdio, time]

stdioInitAll() # VERY IMPORTANT, must be done to use the USB serial port

while true:
  print("Hello, World!\n") # writes string to the serial console
  sleep(5000) # sleep for 5000 milliseconds (5 seconds)
