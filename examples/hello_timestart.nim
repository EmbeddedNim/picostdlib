import picostdlib/[pico/stdio, hardware/timer, pico/time]

stdioInitAll()

while true:
  let timeStart = timeUs32()  # it gets from how long the microcontroller is turned on (32bit, 4294 s)
  let seconds = (float(timeStart) / 1000000.0) # convert from microseconds to seconds
  echo "Time Now : " & $seconds
  echo "Wait 2 seconds..."
  sleepMs(2000) # wait 2 seconds