type Pll*{.importC: "pll_hw_t", header: "hardware/structs/pll.h".} = object
  cs, pwr, fbdiv_int, prim: uint32

{.push header: "hardware/pll.h".}
proc init*(pll: Pll, refDiv, vcoFreq, postDiv1, postDiv2: cuint){.importC: "pll_init".}
proc deinit*(pll: Pll){.importC: "pll_deint".}
{.pop.}
const
  PllSys* {.importC: "pll_sys".} = Pll()
  PllUsb* {.importC: "pll_usb".} = Pll()
