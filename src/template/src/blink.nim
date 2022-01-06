import picostdlib/[gpio, time]

DefaultLedPin.init()
DefaultLedPin.setDir(Out)
while true:
  DefaultLedPin.put(High)
  sleep(250)
  DefaultLedPin.put(Low)
  sleep(250) 
