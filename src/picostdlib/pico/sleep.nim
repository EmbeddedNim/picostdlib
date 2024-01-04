## From pico-extras repository
##
## Lower Power Sleep API
##
## The difference between sleep and dormant is that ALL clocks are stopped in dormant mode,
## until the source (either xosc or rosc) is started again by an external event.
## In sleep mode some clocks can be left running controlled by the SLEEP_EN registers in the clocks
## block. For example you could keep clk_rtc running. Some destinations (proc0 and proc1 wakeup logic)
## can't be stopped in sleep mode otherwise there wouldn't be enough logic to wake up again.
##
## TODO: Optionally, memories can also be powered down.
##

import std/options

from picostdlib import setupDefaultUart
import ../hardware/[rtc, rosc, platform_defs, pll, xosc, sync, structs/scb, timer]
import ./stdio
export rtc, gpio

type
  DormantSource* = enum
    SrcXosc
    SrcRosc

var dormantSourceCache: Option[DormantSource]
var interruptsCache: uint32

proc sleepRunFromDormantSource*(dormantSource: DormantSource) =
  ## Set all clock sources to the the dormant clock source to prepare for sleep.
  ##
  ## \param dormant_source The dormant clock source to use
  dormantSourceCache = some(dormantSource)

  # FIXME: Just defining average rosc freq here.
  let srcHz = if dormantSource == SrcXosc: uint32 XOSC_MHZ * MHz else: uint32 6.5 * MHz
  let clkRefSrc = if dormantSource == SrcXosc:
    ClocksClkRefCtrlSrc.XoscClksrc
  else:
    ClocksClkRefCtrlSrc.RoscClksrcPh

  interruptsCache = saveAndDisableInterrupts()
  # #if MICROPY_PY_NETWORK_CYW43
  # if (cyw43_has_pending) {
  #     restore_interrupts(my_interrupts);
  #     return mp_const_none;
  # }
  # #endif

  # Disable USB and ADC clocks.
  ClockUsb.stop()
  ClockAdc.stop()

  # CLK_REF = XOSC or ROSC
  discard ClockRef.configure(
    clkRefSrc.uint32,
    0, # No aux mux
    srcHz,
    srcHz
  )

  # CLK_SYS = CLK_REF
  discard ClockSys.configure(
    ClocksClkSysCtrlSrc.ClkRef.uint32,
    0, # Using glitchless mux
    srcHz,
    srcHz
  )

  # CLK RTC = ideally XOSC (12MHz) / 256 = 46875Hz but could be rosc
  let clkRtcSrc = if dormantSource == SrcXosc:
    ClocksClkRtcCtrlAuxsrc.XoscClksrc
  else:
    ClocksClkRtcCtrlAuxsrc.RoscClksrcPh

  # CLK_RTC = XOSC / 256
  discard ClockRtc.configure(
    0, # No GLMUX
    clkRtcSrc.uint32,
    srcHz,
    srcHz div 256
  )

  # # CLK PERI = clk_sys. Used as reference clock for Peripherals. No dividers so just select and enable
  # discard ClockPeri.configure(
  #   0,
  #   ClocksClkPeriCtrlAuxsrc.ClkSys.uint32,
  #   srcHz,
  #   srcHz
  # )

  PllSys.deinit()
  PllUsb.deinit()

  # Assuming both xosc and rosc are running at the moment
  if dormantSource == SrcXosc:
    # Can disable rosc
    roscDisable()
  else:
    # Can disable xosc
    xoscDisable()

  # Reconfigure uart with new clocks
  # setupDefaultUart()

proc sleepRunFromXosc*() {.inline.} =
  ## Set the dormant clock source to be the crystal oscillator
  sleepRunFromDormantSource(SrcXosc)

proc sleepRunFromRosc*() {.inline.} =
  ## Set the dormant clock source to be the ring oscillator
  sleepRunFromDormantSource(SrcRosc)

proc sleepGotoSleepDelay*(delayMs: uint32) =
  if dormantSourceCache.isNone: return

  let sleepEn0 = clocksHw.sleep_en0
  let sleepEn1 = clocksHw.sleep_en1

  clocksHw.sleep_en0 = ClocksSleepEn0ClkRtcRtcBits

  # Use timer
  clocksHw.sleep_en1 = ClocksSleepEn1ClkSysTimerBits
  timerHw.alarm[3] = timerHw.timerawl + delayMs * 1000

  # Enable deep sleep at the proc
  scbHw.scr = scbHw.scr or M0PLUS_SCR_SLEEPDEEP_BITS

  # Go to sleep
  wfi()

  scbHw.scr = scbHw.scr and (not M0PLUS_SCR_SLEEPDEEP_BITS)
  clocksHw.sleep_en0 = sleepEn0
  clocksHw.sleep_en1 = sleepEn1

  case dormantSourceCache.get():
  of SrcXosc: roscEnable()
  of SrcRosc: xoscInit()

  clocksInit()
  restoreInterrupts(interruptsCache)
  interruptsCache.reset()


proc sleepGotoSleepUntil*(t: ptr DatetimeT; callback: RtcCallback) =
  ## Send system to sleep until the specified time
  ##
  ## One of the sleep_run_* functions must be called prior to this call
  ##
  ## \param t The time to wake up
  ## \param callback Function to call on wakeup.
  #  We should have already called the sleepRunFromDormantSource function
  if dormantSourceCache.isNone: return

  let sleepEn0 = clocksHw.sleep_en0
  let sleepEn1 = clocksHw.sleep_en1

  clocksHw.sleep_en0 = ClocksSleepEn0ClkRtcRtcBits

  # Use RTC alarm to wake.
  clocksHw.sleep_en1 = 0x00

  rtcSetAlarm(t, callback)

  # Enable deep sleep at the proc
  scbHw.scr = scbHw.scr or M0PLUS_SCR_SLEEPDEEP_BITS

  # Go to sleep
  wfi()

  scbHw.scr = scbHw.scr and (not M0PLUS_SCR_SLEEPDEEP_BITS)
  clocksHw.sleep_en0 = sleepEn0
  clocksHw.sleep_en1 = sleepEn1

  case dormantSourceCache.get():
  of SrcXosc: roscEnable()
  of SrcRosc: xoscInit()

  clocksInit()
  restoreInterrupts(interruptsCache)
  interruptsCache.reset()

proc goDormant*() =
  if dormantSourceCache.isNone: return
  case dormantSourceCache.get():
  of SrcXosc: xoscDormant()
  of SrcRosc: roscSetDormant()

proc leaveDormant*() =
  if dormantSourceCache.isNone: return
  case dormantSourceCache.get():
  of SrcXosc: roscEnable()
  of SrcRosc: xoscInit()
  # clocksInit()

proc sleepGotoDormantUntilPin*(gpio: Gpio; eventMask: set[GpioIrqLevel]) =
  ## Send system to sleep until the specified GPIO changes
  ##
  ## One of the sleep_run_* functions must be called prior to this call
  ##
  ## \param gpio The pin to provide the wake up
  ## \param eventMask Which events will cause an interrupt

  # Configure the appropriate IRQ at IO bank 0
  # assert(gpio_pin < NUM_BANK0_GPIOS)

  gpio.setDormantIrqEnabled(eventMask, true)

  goDormant()
  # Execution stops here until woken up

  # Clear the irq so we can go back to dormant mode again if we want
  gpio.acknowledgeIrq(eventMask)

  leaveDormant()

proc sleepGotoDormantUntilEdgeHigh*(gpio: Gpio) {.inline.} =
  ## Send system to sleep until a leading high edge is detected on GPIO
  ##
  ## One of the sleep_run_* functions must be called prior to this call
  ##
  ## \param gpio The pin to provide the wake up
  sleepGotoDormantUntilPin(gpio, {EdgeRise})

proc sleepGotoDormantUntilLevelHigh*(gpio: Gpio) {.inline.} =
  ## Send system to sleep until a high level is detected on GPIO
  ##
  ## One of the sleep_run_* functions must be called prior to this call
  ##
  ## \param gpio The pin to provide the wake up
  sleepGotoDormantUntilPin(gpio, {LevelHigh})
