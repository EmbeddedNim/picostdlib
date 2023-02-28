import std/strformat
import picostdlib/[pico/stdio, hardware/pll, hardware/clocks]

proc measureFreqs() =
  let
    pllSys = frequencyCountKhz(ClocksFc0Src.PllSysClksrcPrimary)
    pllUsb = frequencyCountKhz(ClocksFc0Src.PllUsbClksrcPrimary)
    rosc = frequencyCountKhz(ClocksFc0Src.RoscClksrc)
    clkSys = frequencyCountKhz(ClocksFc0Src.ClkSys)
    clkPeri = frequencyCountKhz(ClocksFc0Src.ClkPeri)
    clkUsb = frequencyCountKhz(ClocksFc0Src.ClkUsb)
    clkAdc = frequencyCountKhz(ClocksFc0Src.ClkAdc)
    clkRtc = frequencyCountKhz(ClocksFc0Src.ClkRtc)

  echo &"pll_sys = {pllSys}kHz"
  echo &"pll_usb = {pllUsb}kHz"
  echo &"rosc = {rosc}kHz"
  echo &"clk_sys = {clkSys}kHz"
  echo &"clk_peri = {clkPeri}kHz"
  echo &"clk_usb = {clkUsb}kHz"
  echo &"clk_adc = {clkAdc}kHz"
  echo &"clk_rtc = {clkRtc}kHz"

  # Can't measure clk_ref / xosc as it is the ref

stdioInitAll()

echo "Hello, world!"
measureFreqs()

# Change clk_sys to be 48MHz. The simplest way is to take this from PLL_USB
# which has a source frequency of 48MHz
discard clockConfigure(ClockIndex.Sys,
  CtrlSrcValueClkSrcClkSysAux,
  ClocksClkGpoutCtrlAuxSrc.ClksrcPllUsb.uint32,
  48u32 * Mhz,
  48u32 * Mhz)

# Turn off PLL sys for good measure
pllDeinit(PllSys)

# CLK peri is clocked from clk_sys so need to change clk_peri's freq
discard clockConfigure(ClockIndex.Peri,
  0,
  ClocksClkSysCtrlAuxSrc.ClksrcPllUsb.uint32,
  48 * Mhz,
  48 * Mhz)

# Re init uart now that clk_peri has changed
stdioInitAll()

echo "Hello, 48MHz"
measureFreqs()
