# example from pico-playground repository
# not tested
# please see https://github.com/raspberrypi/pico-extras/issues/41

import picostdlib
import picostdlib/pico/sleep

var awake: bool

proc sleepCallback() {.cdecl.} =
  echo "RTC woke us up"
  awake = true

proc rtcSleep() =
  # Start on Friday 5th of June 2020 15:45:00
  var t = DatetimeT(
    year  : 2020,
    month : 6,
    day   : 5,
    dotw  : 5, # 0 is Sunday, so 5 is Friday
    hour  : 15,
    min   : 45,
    sec   : 0
  )

  # Alarm 10 seconds later
  var alarm = DatetimeT(
    year  : 2020,
    month : 6,
    day   : 5,
    dotw  : 5, # 0 is Sunday, so 5 is Friday
    hour  : 15,
    min   : 45,
    sec   : 10
  )

  # Start the RTC
  rtcInit()
  discard rtcSetDatetime(t.addr)

  echo "Sleeping for 10 seconds"
  # uartDefaultTxWaitBlocking()

  sleepGotoSleepUntil(alarm.addr, sleepCallback)

discard stdioInitAll()
echo "Hello Sleep!"

echo "Switching to XOSC"

# Wait for the fifo to be drained so we get reliable output
# uartDefaultTxWaitBlocking()

# UART will be reconfigured by sleep_run_from_xosc
sleepRunFromXosc()

echo "Switched to XOSC"

awake = false

# rtcSleep()
sleepGotoSleepDelay(10 * 1000)

awake = true

# Make sure we don't wake
while not awake:
  echo "Should be sleeping"
  sleepMs(1000)

while true:
  echo "Awake!"
  sleepMs(1000)
