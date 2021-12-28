type 
  AbsoluteTime* {.importc: "absolute_time_t", header: "pico/types.h".} = object
    ## the absolute time (now) of the hardware timer
    time*{.importC: "_private_us_since_boot".}: uint64

  
  DateTime* = object
    year*: 0u16..4095u16
    month*: 1u8..12u8
    day*: 1u8..31u8
    dotw*: 0u8..6u8
    hour*: 0u8..23u8
    min*, sec*: 0u8..59u8

{.push header:"pico/time.h".}
type 
  AlarmCallback* {.importC: "alarm_callback_t".} = proc(id: uint32, data: pointer){.cDecl.}
    ## User alarm callback. 
  AlarmId* = distinct uint32
    ## The identifier for an alarm. 


proc getTime*: AbsoluteTime {.importC:"get_absolute_time".}
  ## Return a representation of the current time.
  ## 
  ## Returns an opaque high fidelity representation of the current time 
  ## sampled during the call.
  ## 
  ## **Returns:** the absolute time (now) of the hardware timer

proc addAlarm*(time: AbsoluteTime, callBack: AlarmCallback, data: pointer, fireIfPast: bool): AlarmId{.importc: "add_alarm_at".}
  ## Add an alarm callback to be called at a specific time. 
  ## 
  ## Generally the callback is called as soon as possible after the time 
  ## specified from an IRQ handler on the core of the default alarm pool 
  ## (generally core 0). If the callback is in the past or happens before the 
  ## alarm setup could be completed, then this method will optionally call the 
  ## callback itself and then return a return code to indicate that the target 
  ## time has passed.
  ## 
  ## **Parameters:**
  ## 
  ## ===============  ====== 
  ## **time**          the timestamp when (after which) the callback should fire 
  ## **callBack**      the callback function 
  ## **data**          user data to pass to the callback function 
  ## **fireIfPast**    if true, this method will call the callback itself before returning 0 if the timestamp happens before or during this method call 
  ## =========
  ## 
  ## **Returns:** 
  ## 
  ## =========  ====== 
  ## **> 0**     the alarm id 
  ## **0**       the target timestamp was during or before this procedure call 
  ## **-1**      if there were no alarm slots available 
  ## =========  ======

proc addAlarm*(ms: uint32, callBack: AlarmCallback, data: pointer, fireIfPast: bool): AlarmId{.importc: "add_alarm_in_ms".}
  ## Add an alarm callback to be called after a delay specified in milliseconds. 
  ## 
  ## Generally the callback is called as soon as possible after the time 
  ## specified from an IRQ handler on the core of the default alarm pool 
  ## (generally core 0). If the callback is in the past or happens before the 
  ## alarm setup could be completed, then this method will optionally call the 
  ## callback itself and then return a return code to indicate that the target 
  ## time has passed.
  ## 
  ## **Parameters:**
  ## 
  ## ===============  ====== 
  ## **ms**            the delay (from now) in milliseconds when (after which) the callback should fire 
  ## **callBack**      the callback function 
  ## **data**          user data to pass to the callback function 
  ## **fireIfPast**    if true, this method will call the callback itself before returning 0 if the timestamp happens before or during this method call 
  ## =========
  ## 
  ## **Returns:** 
  ## 
  ## =========  ====== 
  ## **> 0**     the alarm id 
  ## **0**       the target timestamp was during or before this procedure call 
  ## **-1**      if there were no alarm slots available 
  ## =========  ======

proc addAlarm*(us: uint64, callBack: AlarmCallback, data: pointer, fireIfPast: bool): AlarmId{.importc: "add_alarm_in_us".}
  ## Add an alarm callback to be called at a specific time. 
  ## 
  ## Generally the callback is called as soon as possible after the time 
  ## specified from an IRQ handler on the core of the default alarm pool 
  ## (generally core 0). If the callback is in the past or happens before the 
  ## alarm setup could be completed, then this method will optionally call the 
  ## callback itself and then return a return code to indicate that the target 
  ## time has passed.
  ## 
  ## **Parameters:**
  ## 
  ## ===============  ====== 
  ## **us**            the delay (from now) in microseconds when (after which) the callback should fire 
  ## **callBack**      the callback function 
  ## **data**          user data to pass to the callback function 
  ## **fireIfPast**    if true, this method will call the callback itself before returning 0 if the timestamp happens before or during this method call 
  ## =========
  ## 
  ## **Returns:** 
  ## 
  ## =========  ====== 
  ## **> 0**     the alarm id 
  ## **0**       the target timestamp was during or before this procedure call 
  ## **-1**      if there were no alarm slots available 
  ## =========  ======
proc cancel*(alarm: AlarmId): bool {.importC: "cancel_alarm".}
  ## Cancel an alarm from the default alarm pool. 
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **alarm**       the alarm id 
  ## =============  ======
  ## 
  ## **Returns:**    true if the alarm was cancelled, false if it didn't exist 



{.push header: "hardware/timer.h".}
proc timeUs32*(): uint32 {.importC: "time_us_32".}
  ## Return time from the start of the microcontroller to microseconds (32-bit) 
  
proc timeUs64*(): uint64 {.importC: "time_us_64".}
  ## ## Return time from the start of the microcontroller to microseconds (64-bit)
{.pop.}


