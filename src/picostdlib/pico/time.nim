import ./types
export types

{.push header: "pico/time.h".}

type 
  AlarmId* {.importc: "alarm_id_t".} = distinct int32
    ## ```
    ##   ! \brief The identifier for an alarm
    ##   
    ##    \note this identifier is signed because -1 is used as an error condition when creating alarms
    ##   
    ##    \note alarm ids may be reused, however for convenience the implementation makes an attempt to defer
    ##    reusing as long as possible. You should certainly expect it to be hundreds of ids before one is
    ##    reused, although in most cases it is more. Nonetheless care must still be taken when cancelling
    ##    alarms or other functionality based on alarms when the alarm may have expired, as eventually
    ##    the alarm id may be reused for another alarm.
    ##   
    ##    \ingroup alarm
    ## ```

  AlarmCallback* {.importc: "alarm_callback_t".} = proc(id: AlarmId, userData: pointer) {.cdecl.}
    ## ```
    ##   ! \brief User alarm callback
    ##    \ingroup alarm
    ##    \param id the alarm_id as returned when the alarm was added
    ##    \param user_data the user data passed when the alarm was added
    ##    \return <0 to reschedule the same alarm this many us from the time the alarm was previously scheduled to fire
    ##    \return >0 to reschedule the same alarm this many us from the time this method returns
    ##    \return 0 to not reschedule the alarm
    ## ```
  
  AlarmPool* {.importc: "struct alarm_pool".} = object
  
  RepeatingTimer* {.bycopy, importc: "struct repeating_timer".} = object
    ## Information about a repeating timer
    delay_us*: int64
    pool*: ptr AlarmPool
    alarm_id*: AlarmId
    callback*: RepeatingTimerCallback
    user_data*: pointer

  RepeatingTimerCallback* {.importc: "repeating_timer_callback_t".} = proc (rt: ptr RepeatingTimer): bool {.cdecl.}
    ## ```
    ##   ! \brief Callback for a repeating timer
    ##    \ingroup repeating_timer
    ##    \param rt repeating time structure containing information about the repeating time. user_data is of primary important to the user
    ##    \return true to continue repeating, false to stop.
    ## ```

let
  atTheEndOfTime* {.importc: "at_the_end_of_time".}: AbsoluteTime
    ## The timestamp representing the end of time; this is actually not the maximum possible
    ## timestamp, but is set to 0x7fffffff_ffffffff microseconds to avoid sign overflows with time
    ## arithmetic. This is still over 7 million years, so should be sufficient.

  nilTime* {.importc: "nil_time".}: AbsoluteTime
    ## The timestamp representing a null timestamp


## MODULE TIMESTAMP

proc getAbsoluteTime*: AbsoluteTime {.importc: "get_absolute_time".}
  ## Return a representation of the current time.
  ## 
  ## Returns an opaque high fidelity representation of the current time 
  ## sampled during the call.
  ## 
  ## **Returns:** the absolute time (now) of the hardware timer

proc toMsSinceBoot*(t: AbsoluteTime): uint32 {.importc: "to_ms_since_boot".}
  ## ```
  ##   ! fn to_ms_since_boot
  ##    \ingroup timestamp
  ##    \brief Convert a timestamp into a number of milliseconds since boot.
  ##    \param t an absolute_time_t value to convert
  ##    \return the number of milliseconds since boot represented by t
  ##    \sa to_us_since_boot()
  ## ```

proc delayedByUs*(t: AbsoluteTime; us: uint64): AbsoluteTime {.importc: "delayed_by_us".}
  ## ```
  ##   ! \brief Return a timestamp value obtained by adding a number of microseconds to another timestamp
  ##    \ingroup timestamp
  ##   
  ##    \param t the base timestamp
  ##    \param us the number of microseconds to add
  ##    \return the timestamp representing the resulting time
  ## ```

proc delayedByMs*(t: AbsoluteTime; ms: uint32): AbsoluteTime {.importc: "delayed_by_ms".}
  ## ```
  ##   ! \brief Return a timestamp value obtained by adding a number of milliseconds to another timestamp
  ##    \ingroup timestamp
  ##   
  ##    \param t the base timestamp
  ##    \param ms the number of milliseconds to add
  ##    \return the timestamp representing the resulting time
  ## ```

proc makeTimeoutTimeUs*(us: uint64): AbsoluteTime {.importc: "make_timeout_time_us".}
  ## ```
  ##   ! \brief Convenience method to get the timestamp a number of microseconds from the current time
  ##    \ingroup timestamp
  ##   
  ##    \param us the number of microseconds to add to the current timestamp
  ##    \return the future timestamp
  ## ```

proc makeTimeoutTimeMs*(ms: uint32): AbsoluteTime {.importc: "make_timeout_time_ms".}
  ## ```
  ##   ! \brief Convenience method to get the timestamp a number of milliseconds from the current time
  ##    \ingroup timestamp
  ##   
  ##    \param ms the number of milliseconds to add to the current timestamp
  ##    \return the future timestamp
  ## ```

proc absoluteTimeDiffUs*(`from`: AbsoluteTime; to: AbsoluteTime): int64 {.importc: "absolute_time_diff_us".}
  ## ```
  ##   ! \brief Return the difference in microseconds between two timestamps
  ##    \ingroup timestamp
  ##   
  ##    \note be careful when diffing against large timestamps (e.g. \ref at_the_end_of_time)
  ##    as the signed integer may overflow.
  ##   
  ##    \param from the first timestamp
  ##    \param to the second timestamp
  ##    \return the number of microseconds between the two timestamps (positive if to is after from except
  ##    in case of overflow)
  ## ```

proc isAtTheEndOfTime*(t: AbsoluteTime): bool {.importc: "is_at_the_end_of_time".}
  ## ```
  ##   ! \brief Determine if the given timestamp is "at_the_end_of_time"
  ##    \ingroup timestamp
  ##     \param t the timestamp
  ##     \return true if the timestamp is at_the_end_of_time
  ##     \sa at_the_end_of_time
  ## ```

proc isNilTime*(t: AbsoluteTime): bool {.importc: "is_nil_time".}
  ## ```
  ##   ! \brief Determine if the given timestamp is nil
  ##    \ingroup timestamp
  ##     \param t the timestamp
  ##     \return true if the timestamp is nil
  ##     \sa nil_time
  ## ```


## MODULE SLEEP

proc sleepUntil*(target: AbsoluteTime) {.importc: "sleep_until".}
  ## ```
  ##   ! \brief Wait until after the given timestamp to return
  ##    \ingroup sleep
  ##   
  ##    \note  This method attempts to perform a lower power (WFE) sleep
  ##   
  ##    \param target the time after which to return
  ##    \sa sleep_us()
  ##    \sa busy_wait_until()
  ## ```

proc sleepUs*(us: uint64) {.importc: "sleep_us".}
  ## Wait for the given number of microseconds before returning. 
  ## 
  ## Note: This procedure attempts to perform a lower power sleep (using WFE) as much as possible.
  ##
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **us**     the number of microseconds to sleep 

proc sleepMs*(ms: uint32) {.importc: "sleep_ms".}
  ## Wait for the given number of milliseconds before returning. 
  ## 
  ## Note: This procedure attempts to perform a lower power sleep (using WFE) as much as possible.
  ##
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **ms**     the number of milliseconds to sleep 

proc bestEffortWfeOrTimeout*(timeoutTimestamp: AbsoluteTime): bool {.importc: "best_effort_wfe_or_timeout".}
  ## ```
  ##   ! \brief Helper method for blocking on a timeout
  ##    \ingroup sleep
  ##   
  ##    This method will return in response to an event (as per __wfe) or
  ##    when the target time is reached, or at any point before.
  ##   
  ##    This method can be used to implement a lower power polling loop waiting on
  ##    some condition signalled by an event (__sev()).
  ##   
  ##    This is called \a best_effort because under certain circumstances (notably the default timer pool
  ##    being disabled or full) the best effort is simply to return immediately without a __wfe, thus turning the calling
  ##    code into a busy wait.
  ##   
  ##    Example usage:
  ##    ```c
  ##    bool my_function_with_timeout_us(uint64_t timeout_us) {
  ##        absolute_time_t timeout_time = make_timeout_time_us(timeout_us);
  ##        do {
  ##            // each time round the loop, we check to see if the condition
  ##            // we are waiting on has happened
  ##            if (my_check_done()) {
  ##                // do something
  ##                return true;
  ##            }
  ##            // will try to sleep until timeout or the next processor event 
  ##        } while (!best_effort_wfe_or_timeout(timeout_time));
  ##        return false; // timed out
  ##    }
  ##    ```
  ##   
  ##    @param timeout_timestamp the timeout time
  ##    @return true if the target time is reached, false otherwise
  ## ```


## MODULE ALARM

proc alarmPoolInitDefault*() {.importc: "alarm_pool_init_default".}
  ## ```
  ##   \brief Create the default alarm pool (if not already created or disabled)
  ##    \ingroup alarm
  ## ```

proc alarmPoolGetDefault*(): ptr AlarmPool {.importc: "alarm_pool_get_default".}
  ## ```
  ##   ! \brief The default alarm pool used when alarms are added without specifying an alarm pool,
  ##           and also used by the SDK to support lower power sleeps and timeouts.
  ##   
  ##    \ingroup alarm
  ##    \sa #PICO_TIME_DEFAULT_ALARM_POOL_HARDWARE_ALARM_NUM
  ## ```

proc alarmPoolCreate*(hardwareAlarmNum: cuint; maxTimers: cuint): ptr AlarmPool {.importc: "alarm_pool_create".}
  ## ```
  ##   \brief Create an alarm pool
  ##   
  ##    The alarm pool will call callbacks from an alarm IRQ Handler on the core of this function is called from.
  ##   
  ##    In many situations there is never any need for anything other than the default alarm pool, however you
  ##    might want to create another if you want alarm callbacks on core 1 or require alarm pools of
  ##    different priority (IRQ priority based preemption of callbacks)
  ##   
  ##    \note This method will hard assert if the hardware alarm is already claimed.
  ##   
  ##    \ingroup alarm
  ##    \param hardware_alarm_num the hardware alarm to use to back this pool
  ##    \param max_timers the maximum number of timers
  ##           \note For implementation reasons this is limited to PICO_PHEAP_MAX_ENTRIES which defaults to 255
  ##    \sa alarm_pool_get_default()
  ##    \sa hardware_claiming
  ## ```

proc alarmPoolHardwareAlarmNum*(pool: ptr AlarmPool): cuint {.importc: "alarm_pool_hardware_alarm_num".}
  ## ```
  ##   \brief Return the hardware alarm used by an alarm pool
  ##    \ingroup alarm
  ##    \param pool the pool
  ##    \return the hardware alarm used by the pool
  ## ```

proc alarmPoolDestroy*(pool: ptr AlarmPool) {.importc: "alarm_pool_destroy".}
  ## ```
  ##   \brief Destroy the alarm pool, cancelling all alarms and freeing up the underlying hardware alarm
  ##    \ingroup alarm
  ##    \param pool the pool
  ##    \return the hardware alarm used by the pool
  ## ```

proc alarmPoolAddAlarmAt*(pool: ptr AlarmPool; time: AbsoluteTime; callback: AlarmCallback; userData: pointer; fireIfPast: bool): AlarmId {.importc: "alarm_pool_add_alarm_at".}
  ## ```
  ##   !
  ##    \brief Add an alarm callback to be called at a specific time
  ##    \ingroup alarm
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core the alarm pool was created on. If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param pool the alarm pool to use for scheduling the callback (this determines which hardware alarm is used, and which core calls the callback)
  ##    @param time the timestamp when (after which) the callback should fire
  ##    @param callback the callback function
  ##    @param user_data user data to pass to the callback function
  ##    @param fire_if_past if true, and the alarm time falls before or during this call before the alarm can be set,
  ##                        then the callback should be called during (by) this function instead 
  ##    @return >0 the alarm id for an active (at the time of return) alarm
  ##    @return 0 if the alarm time passed before or during the call AND there is no active alarm to return the id of.
  ##              The latter can either happen because fire_if_past was false (i.e. no timer was ever created),
  ##              or if the callback <i>was</i> called during this method but the callback cancelled itself by returning 0
  ##    @return -1 if there were no alarm slots available
  ## ```

proc alarmPoolAddAlarmInUs*(pool: ptr AlarmPool; us: uint64; callback: AlarmCallback; userData: pointer; fireIfPast: bool): AlarmId {.importc: "alarm_pool_add_alarm_in_us".}
  ## ```
  ##   !
  ##    \brief Add an alarm callback to be called after a delay specified in microseconds
  ##    \ingroup alarm
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core the alarm pool was created on. If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param pool the alarm pool to use for scheduling the callback (this determines which hardware alarm is used, and which core calls the callback)
  ##    @param us the delay (from now) in microseconds when (after which) the callback should fire
  ##    @param callback the callback function
  ##    @param user_data user data to pass to the callback function
  ##    @param fire_if_past if true, and the alarm time falls during this call before the alarm can be set,
  ##                        then the callback should be called during (by) this function instead 
  ##    @return >0 the alarm id
  ##    @return 0 if the alarm time passed before or during the call AND there is no active alarm to return the id of.
  ##              The latter can either happen because fire_if_past was false (i.e. no timer was ever created),
  ##              or if the callback <i>was</i> called during this method but the callback cancelled itself by returning 0
  ##    @return -1 if there were no alarm slots available
  ## ```

proc alarmPoolAddAlarmInMs*(pool: ptr AlarmPool; ms: uint32; callback: AlarmCallback; userData: pointer; fireIfPast: bool): AlarmId {.importc: "alarm_pool_add_alarm_in_ms".}
  ## ```
  ##   !
  ##    \brief Add an alarm callback to be called after a delay specified in milliseconds
  ##    \ingroup alarm
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core the alarm pool was created on. If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param pool the alarm pool to use for scheduling the callback (this determines which hardware alarm is used, and which core calls the callback)
  ##    @param ms the delay (from now) in milliseconds when (after which) the callback should fire
  ##    @param callback the callback function
  ##    @param user_data user data to pass to the callback function
  ##    @param fire_if_past if true, and the alarm time falls before or during this call before the alarm can be set,
  ##                        then the callback should be called during (by) this function instead 
  ##    @return >0 the alarm id
  ##    @return 0 if the alarm time passed before or during the call AND there is no active alarm to return the id of.
  ##              The latter can either happen because fire_if_past was false (i.e. no timer was ever created),
  ##              or if the callback <i>was</i> called during this method but the callback cancelled itself by returning 0
  ##    @return -1 if there were no alarm slots available
  ## ```

proc alarmPoolCancelAlarm*(pool: ptr AlarmPool; alarmId: AlarmId): bool {.importc: "alarm_pool_cancel_alarm".}
  ## ```
  ##   !
  ##    \brief Cancel an alarm
  ##    \ingroup alarm
  ##    \param pool the alarm_pool containing the alarm
  ##    \param alarm_id the alarm
  ##    \return true if the alarm was cancelled, false if it didn't exist
  ##    \sa alarm_id_t for a note on reuse of IDs
  ## ```

proc addAlarmAt*(time: AbsoluteTime; callback: AlarmCallback; userData: pointer; fireIfPast: bool): AlarmId {.importc: "add_alarm_at".}
  ## ```
  ##   !
  ##    \brief Add an alarm callback to be called at a specific time
  ##    \ingroup alarm
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core of the default alarm pool (generally core 0). If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param time the timestamp when (after which) the callback should fire
  ##    @param callback the callback function
  ##    @param user_data user data to pass to the callback function
  ##    @param fire_if_past if true, and the alarm time falls before or during this call before the alarm can be set,
  ##                        then the callback should be called during (by) this function instead 
  ##    @return >0 the alarm id
  ##    @return 0 if the alarm time passed before or during the call AND there is no active alarm to return the id of.
  ##              The latter can either happen because fire_if_past was false (i.e. no timer was ever created),
  ##              or if the callback <i>was</i> called during this method but the callback cancelled itself by returning 0
  ##    @return -1 if there were no alarm slots available
  ## ```

proc addAlarmInUs*(us: uint64; callback: AlarmCallback; userData: pointer; fire_if_past: bool): AlarmId {.importc: "add_alarm_in_us".}
  ## ```
  ##   !
  ##    \brief Add an alarm callback to be called after a delay specified in microseconds
  ##    \ingroup alarm
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core of the default alarm pool (generally core 0). If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param us the delay (from now) in microseconds when (after which) the callback should fire
  ##    @param callback the callback function
  ##    @param user_data user data to pass to the callback function
  ##    @param fire_if_past if true, and the alarm time falls during this call before the alarm can be set,
  ##                        then the callback should be called during (by) this function instead 
  ##    @return >0 the alarm id
  ##    @return 0 if the alarm time passed before or during the call AND there is no active alarm to return the id of.
  ##              The latter can either happen because fire_if_past was false (i.e. no timer was ever created),
  ##              or if the callback <i>was</i> called during this method but the callback cancelled itself by returning 0
  ##    @return -1 if there were no alarm slots available
  ## ```

proc addAlarmInMs*(ms: uint32; callback: AlarmCallback; userData: pointer; fireIfPast: bool): AlarmId {.importc: "add_alarm_in_ms".}
  ## ```
  ##   !
  ##    \brief Add an alarm callback to be called after a delay specified in milliseconds
  ##    \ingroup alarm
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core of the default alarm pool (generally core 0). If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param ms the delay (from now) in milliseconds when (after which) the callback should fire
  ##    @param callback the callback function
  ##    @param user_data user data to pass to the callback function
  ##    @param fire_if_past if true, and the alarm time falls during this call before the alarm can be set,
  ##                        then the callback should be called during (by) this function instead 
  ##    @return >0 the alarm id
  ##    @return 0 if the alarm time passed before or during the call AND there is no active alarm to return the id of.
  ##              The latter can either happen because fire_if_past was false (i.e. no timer was ever created),
  ##              or if the callback <i>was</i> called during this method but the callback cancelled itself by returning 0
  ##    @return -1 if there were no alarm slots available
  ## ```

proc cancelAlarm*(alarmId: AlarmId): bool {.importc: "cancel_alarm".}
  ## ```
  ##   !
  ##    \brief Cancel an alarm from the default alarm pool
  ##    \ingroup alarm
  ##    \param alarm_id the alarm
  ##    \return true if the alarm was cancelled, false if it didn't exist
  ##    \sa alarm_id_t for a note on reuse of IDs
  ## ```


## MODULE REPEATING TIMER

proc alarmPoolAddRepeatingTimerUs*(pool: ptr AlarmPool; delayUs: int64; callback: RepeatingTimerCallback; userData: pointer; `out`: ptr RepeatingTimer): bool {.importc: "alarm_pool_add_repeating_timer_us".}
  ## ```
  ##   !
  ##    \brief Add a repeating timer that is called repeatedly at the specified interval in microseconds
  ##    \ingroup repeating_timer
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core the alarm pool was created on. If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param pool the alarm pool to use for scheduling the repeating timer (this determines which hardware alarm is used, and which core calls the callback)
  ##    @param delay_us the repeat delay in microseconds; if >0 then this is the delay between one callback ending and the next starting; if <0 then this is the negative of the time between the starts of the callbacks. The value of 0 is treated as 1
  ##    @param callback the repeating timer callback function
  ##    @param user_data user data to pass to store in the repeating_timer structure for use by the callback.
  ##    @param out the pointer to the user owned structure to store the repeating timer info in. BEWARE this storage location must outlive the repeating timer, so be careful of using stack space
  ##    @return false if there were no alarm slots available to create the timer, true otherwise.
  ## ```

proc alarmPoolAddRepeatingTimerMs*(pool: ptr AlarmPool; delayMs: int32; callback: RepeatingTimerCallback; userData: pointer; `out`: ptr RepeatingTimer): bool {.importc: "alarm_pool_add_repeating_timer_ms".}
  ## ```
  ##   !
  ##    \brief Add a repeating timer that is called repeatedly at the specified interval in milliseconds
  ##    \ingroup repeating_timer
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core the alarm pool was created on. If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param pool the alarm pool to use for scheduling the repeating timer (this determines which hardware alarm is used, and which core calls the callback)
  ##    @param delay_ms the repeat delay in milliseconds; if >0 then this is the delay between one callback ending and the next starting; if <0 then this is the negative of the time between the starts of the callbacks. The value of 0 is treated as 1 microsecond
  ##    @param callback the repeating timer callback function
  ##    @param user_data user data to pass to store in the repeating_timer structure for use by the callback.
  ##    @param out the pointer to the user owned structure to store the repeating timer info in. BEWARE this storage location must outlive the repeating timer, so be careful of using stack space
  ##    @return false if there were no alarm slots available to create the timer, true otherwise.
  ## ```

proc addRepeatingTimerUs*(delayUs: int64; callback: RepeatingTimerCallback; userData: pointer; `out`: ptr RepeatingTimer): bool {.importc: "add_repeating_timer_us".}
  ## ```
  ##   !
  ##    \brief Add a repeating timer that is called repeatedly at the specified interval in microseconds
  ##    \ingroup repeating_timer
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core of the default alarm pool (generally core 0). If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param delay_us the repeat delay in microseconds; if >0 then this is the delay between one callback ending and the next starting; if <0 then this is the negative of the time between the starts of the callbacks. The value of 0 is treated as 1
  ##    @param callback the repeating timer callback function
  ##    @param user_data user data to pass to store in the repeating_timer structure for use by the callback.
  ##    @param out the pointer to the user owned structure to store the repeating timer info in. BEWARE this storage location must outlive the repeating timer, so be careful of using stack space
  ##    @return false if there were no alarm slots available to create the timer, true otherwise.
  ## ```

proc addRepeatingTimerMs*(delayMs: int32; callback: RepeatingTimerCallback; userData: pointer; `out`: ptr RepeatingTimer): bool {.importc: "add_repeating_timer_ms".}
  ## ```
  ##   !
  ##    \brief Add a repeating timer that is called repeatedly at the specified interval in milliseconds
  ##    \ingroup repeating_timer
  ##   
  ##    Generally the callback is called as soon as possible after the time specified from an IRQ handler
  ##    on the core of the default alarm pool (generally core 0). If the callback is in the past or happens before
  ##    the alarm setup could be completed, then this method will optionally call the callback itself
  ##    and then return a return code to indicate that the target time has passed.
  ##   
  ##    \note It is safe to call this method from an IRQ handler (including alarm callbacks), and from either core.
  ##   
  ##    @param delay_ms the repeat delay in milliseconds; if >0 then this is the delay between one callback ending and the next starting; if <0 then this is the negative of the time between the starts of the callbacks. The value of 0 is treated as 1 microsecond
  ##    @param callback the repeating timer callback function
  ##    @param user_data user data to pass to store in the repeating_timer structure for use by the callback.
  ##    @param out the pointer to the user owned structure to store the repeating timer info in. BEWARE this storage location must outlive the repeating timer, so be careful of using stack space
  ##    @return false if there were no alarm slots available to create the timer, true otherwise.
  ## ```

proc cancelRepeatingTimer*(timer: ptr RepeatingTimer): bool {.importc: "cancel_repeating_timer".}
  ## ```
  ##    \brief Cancel a repeating timer
  ##    \ingroup repeating_timer
  ##    \param timer the repeating timer to cancel
  ##    \return true if the repeating timer was cancelled, false if it didn't exist
  ##    \sa alarm_id_t for a note on reuse of IDs
  ## ```

{.pop.}
