import ../pico/types

{.push header:"hardware/rtc.h".}

type
  RtcCallback* {.importc: "rtc_callback_t".} = proc () {.noconv.}

proc rtcInit*() {.importc: "rtc_init".}
  ## ```
  ##   ! \brief Initialise the RTC system
  ##     \ingroup hardware_rtc
  ## ```

proc rtcSetDateTime*(t: ptr DateTime): bool {.importc: "rtc_set_datetime".}
  ## ```
  ##   ! \brief Set the RTC to the specified time
  ##     \ingroup hardware_rtc
  ##   
  ##    \note Note that after setting the RTC date and time, a subsequent read of the values (e.g. via rtc_get_datetime()) may not
  ##    reflect the new setting until up to three cycles of the potentially-much-slower RTC clock domain have passed. This represents a period
  ##    of 64 microseconds with the default RTC clock configuration.
  ##   
  ##    \param t Pointer to a \ref datetime_t structure contains time to set
  ##    \return true if set, false if the passed in datetime was invalid.
  ## ```

proc rtcGetDateTime*(t: ptr DateTime): bool {.importc: "rtc_get_datetime".}
  ## ```
  ##   ! \brief Get the current time from the RTC
  ##     \ingroup hardware_rtc
  ##   
  ##    \param t Pointer to a \ref datetime_t structure to receive the current RTC time
  ##    \return true if datetime is valid, false if the RTC is not running.
  ## ```

proc rtcRunning*(): bool {.importc: "rtc_running".}
  ## ```
  ##   ! \brief Is the RTC running?
  ##     \ingroup hardware_rtc
  ## ```

proc rtcSetAlarm*(t: ptr DateTime; userCallback: RtcCallback) {.importc: "rtc_set_alarm".}
  ## ```
  ##   ! \brief Set a time in the future for the RTC to call a user provided callback
  ##     \ingroup hardware_rtc
  ##   
  ##     \param t Pointer to a \ref datetime_t structure containing a time in the future to fire the alarm. Any values set to -1 will not be matched on.
  ##     \param user_callback pointer to a \ref rtc_callback_t to call when the alarm fires
  ## ```

proc rtcEnableAlarm*() {.importc: "rtc_enable_alarm".}
  ## ```
  ##   ! \brief Enable the RTC alarm (if inactive)
  ##     \ingroup hardware_rtc
  ## ```

proc rtcDisableAlarm*() {.importc: "rtc_disable_alarm".}
  ## ```
  ##   ! \brief Disable the RTC alarm (if active)
  ##     \ingroup hardware_rtc
  ## ```

{.pop.}
