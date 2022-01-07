import picostdlib/[time, stdio]

stdioInitAll()

while true:
  var timeStart = timeUs32()  #it gets from how long the microcontroller is turned on (32bit, 4294 s)
  var seconds = (float(timeStart) / 1000000.0) #convert from microseconnds to seconds
  print("Time Now : " & $seconds & '\n')
  print("Wait 2 seconds.." & '\n')
  sleep(2000) #wait 2 seconds
