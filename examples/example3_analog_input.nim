## Raspberry Pi Pico SDK for Nim, 
## Example 3 - Analog Input
##
## This program will read an analog signal (from a potentiometer) and give it
## a digital value. The usefulness of Analog to Digital Conversion (ADC) comes 
## into play when using many types of sensors and output devices.

import picostdlib/[gpio, adc, time, stdio]
import std/[strutils, strformat]

stdioInitAll() # VERY IMPORTANT, must be done to use the USB serial port
adcInit() # initialize the adc module

# we attached the centre pin of a 10k potentiometer to Gpio 26
let adcPin = 26.Gpio # define the ADC pin. note only certain pins may be used

adcPin.init() # initialize the pin
Adc26.selectInput() # select the ADC pin that we should be paying attention to

while true:
  let 
    # adcRead() will give a uint16 value between 0 and 4095 
    read = adcRead() # get an analog reading from the selected input (Adc26)
    raw = intToStr(int(read)) # first covert read to int, and then to a string
    voltage = formatFloat((read.float * ThreePointThreeConv), ffDecimal, 4)
    msg = fmt"Raw value: {raw} , Voltage: {voltage}"
  
  print(msg) # print out the raw value (between 0 and 4095) and the voltage
  sleep(500)
