import std/volatile
import picostdlib
import picostdlib/[hardware/pll, hardware/clocks]

var seenResus: bool

# Uses the LedPin to indicate life since I cannot see the response on the usb connection.

proc resusCallback {.cdecl.} =
  #  Reconfigure PLL sys back to the default state of 1500 / 6 / 2 = 125MHz
  PllSys.pllInit(1, 1500 * Mhz, 6, 2)

  # CLK SYS = PLL SYS (125MHz) / 1 = 125MHz
  discard clockConfigure(ClockIndex.Sys,
    CtrlSrcValueClksrcClkSysAux,
    CtrlAuxsrcValueClksrcPllSys,
    125 * Mhz,
    125 * Mhz)
  
  # Reconfigure uart as clocks have changed
  stdioInitAll()
  echo "Resus event fired"

  # Wait for uart output to finish
  uartDefaultTxWaitBlocking()

  gpioInit(PicoDefaultLedPin)
  gpioSetDir(PicoDefaultLedPin, Out)
  gpioPut(PicoDefaultLedPin, High)

  volatileStore(seenResus.addr, true)


# need to be inside proc to use volatile
# https://github.com/nim-lang/Nim/issues/14623
proc main() =
  stdioInitAll()
  echo "Hello resus"

  volatileStore(seenResus.addr, false)

  clocksEnableResus(resusCallback)

  # Break PLL sys
  pllDeinit(PllSys)

  while not volatileLoad(seenResus.addr):
    tightLoopContents()

  sleepMs(1000)
  gpioPut(PicoDefaultLedPin, Low)

main()
