import std/volatile
import picostdlib/[pico/stdio, hardware/rtc, pico/util/datetime, pico/time, pico/platform]

var fired = false

proc alarmCallback() {.cdecl.} =
  var t: Datetime
  discard rtcGetDatetime(t.addr)
  echo "Alarm fired at " & datetimeToStr(t)
  stdioFlush()
  volatileStore(fired.addr, true)

# need to be inside proc to use volatile
# https://github.com/nim-lang/Nim/issues/14623
proc main() =
  stdioInitAll()
  echo "RTC Alarm!"

  # Start on Wednesday 13th January 2021 11:20:00
  var t = Datetime(
    year: 2020,
    month: 01,
    day: 13,
    dotw: 3, # 0 is Sunday, so 3 is Wednesday
    hour: 11,
    min: 20,
    sec: 00
  )

  # Start the RTC
  rtcInit()
  if not rtcSetDatetime(t.addr):
    echo "Setting RTC failed."
  else:
    var alarm = Datetime(
      year: 2020,
      month: 01,
      day: 13,
      dotw: 3, # 0 is Sunday, so 3 is Wednesday
      hour: 11,
      min: 20,
      sec: 05
    )

    rtcSetAlarm(alarm.addr, alarmCallback)

    while not volatileLoad(fired.addr):
      tightLoopContents()

main()
