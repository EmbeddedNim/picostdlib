import picostdlib
import picostdlib/[pll, clock]
proc measure =
  let
    pllSys = frequencyCountKhz(pllSysClksrcPrimary)
    pllUsb = frequencyCountKhz(pllUsbClksrcPrimary)
    rosc = frequencyCountKhz(Fc0SrcValue.roscClksrc)
    clkSys = frequencyCountKhz(clkSys)
    clkPeri = frequencyCountKhz(clkPeri)
    clkUsb = frequencyCountKhz(clkUsb)
    clkAdc = frequencyCountKhz(clkAdc)
    clkRtc = frequencyCountKhz(clkRtc)

  print("pll_sys = " & $pllSys)
  print("pll_usb = " & $pllUsb)
  print("rosc = " & $rosc)
  print("clk_sys = " & $clkSys)
  print("clk_peri = " & $clkPeri)
  print("clk_usb = " & $clkUsb)
  print("clk_adc = " & $clkAdc)
  print("clk_rtc = " & $clkRtc)

stdioInitAll()
print("Hello world")
measure()
discard clockConfigure(ClockIndex.sys,
  CtrlSrcValueClkSrcClkSysAux,
  AuxSrcValue.clksrcPllUsb.uint32,
  48u32 * Mhz,
  48u32 * Mhz)
PllSys.deinit()
discard clockConfigure(ClockIndex.peri, 0u32, AuxSrcValue.clksrcPllUsb.ord.uint32,
  48u32 * Mhz,
  48u32 * Mhz)
stdioInitAll()
measure()
print("Hello, 48MHz")
