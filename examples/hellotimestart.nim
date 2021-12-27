import picostdlib/[gpio, time]
import picostdlib

stdioInitAll()
var oldTime: uint32 = 0
while true:
  var timeStart = timeUs32()  #it gets from how long the microcontroller is turned on (32bit, 4294 s)
  var seconds = float(float(timeStart) / 1000000.0) #convert from microseconnds to seconds
  print("Time Now : " & $seconds & '\n')
  print("Wait 2 seconds.." & '\n')
  if timeStart <= oldTime:
    print("The time is restart from 0" & '\n')
  oldTime = timeStart #store the current time in the variable 
  sleep(2000) #wait 2 seconds
