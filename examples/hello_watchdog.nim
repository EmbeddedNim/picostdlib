import picostdlib/[watchdog, stdio, time]


stdioInitAll()
sleep(1000)
while true:
  if watchdogCausedReboot() == true:
    print("Reboot by WatchDog!" & '\n')
  else:
    print("Clean Boot" & '\n')

  watchdogEnable(100, true)

  for i in countup(0,5):
    print("Updating Watchdog" & $i & '\n')
    watchdogUpdate()

  print("Waiting to be Rebooted by Watchdog" & '\n')

  while true:
    sleep(50)
    
#[ in ...csource/CMakeLists.txt add target_link_libraries(tests pico_stdlib hardware_adc) 
add--> (hardware_watchdog) ]#
