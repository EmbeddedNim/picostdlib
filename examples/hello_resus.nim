import picostdlib/[pll, clock, gpio, stdio]
var seenResus = false
# Uses the LedPin to indicate life since I cannot see the response on the usb connection.
proc resusCallback {.noConv.} =
  PllSys.init(1, 1500 * Mhz, 6, 2)
  discard clockConfigure(ClockIndex.sys, CtrlSrcValueClksrcClkSysAux, CtrlAuxsrcValueClksrcPllSys,
      125u32 * Mhz, 125u32 * Mhz)
  stdioInitAll()
  print("Resus event fired \n")
  defaultTxWaitBlocking()
  DefaultLedPin.init
  DefaultLedPin.setDir(Out)
  DefaultLedPin.put(High)
  seenResus = true


proc main() =
  enableResus(resusCallback)
  stdioInitAll()

  print("Hello resus \n")
  seenResus = false
  PllSys.deinit
  while not seenResus: discard
  sleep(1000)
  DefaultLedPin.put(Low)

main()
