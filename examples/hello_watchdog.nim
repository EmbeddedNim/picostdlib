import picostdlib/[gpio, watchdog]
import picostdlib


stdioInitAll()
sleep(1000)
while true:
  if watchdogCauseReboot() == true:
    print("Reboot by WatchDog!" & '\n')
  else:
    print("Clean Boot" & '\n')

  watchdogEnable(100, true)

  for i in countup(0,5):
    print("Updating Watchdog" & $i & '\n')
    watchdogUpade()

  print("Waiting to be Rebooted by Watchdog" & '\n')

  while true:
    sleep(50)