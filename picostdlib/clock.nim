
{.push header: "hardware/structs/clocks.h".}
type
  ClockIndex* {.pure, importC: "enum clock_index".} = enum
    gpOut0
    gpOut1
    gpOut2
    gpOut3
    ciRef
    sys
    peri
    usb
    adc
    rtc
{.pop.}

type
  Fc0SrcValue* {.pure, size: sizeof(cuint).} = enum
    null
    pllSysClksrcPrimary
    pllUsbClksrcPrimary
    roscClksrc
    roscClksrcPh
    xoscClksrc
    clksrcGpin0
    clksrcGpin1
    clkRef
    clkSys
    clkPeri
    clkUsb
    clkAdc
    clkRtc
  AuxSrcValue* {.pure, size: sizeof(cuint).} = enum
    clksrcPllSys
    clksrcPllUsb
    roscClksrc
    xoscClksrc
    clkSrcGpin0
    clkSrcGpin1
  ResusCallback* = proc(){.noConv.}

const
  Fc0SrcOffset* = 0x00000094u32
  Fc0SrcBits* = 0x000000ffu32
  Fc0SrcReset* = 0x00000000u32
  Fc0SrcMsb* = 7u32
  Fc0SrcLsb* = 0u32
  Fc0SrcAccess* = "RW"
  Fc0SrcValueNull* = 0x00u32

  CtrlAuxsrcReset* = 0u32
  CtrlAuxsrcBits* = 0xe0u32
  CtrlAuxsrcMsb* = 7u32
  CtrlAuxsrcLsb* = 0u32
  CtrlAuxsrcAccess* = "RW"
  CtrlAuxsrcValueClksrcPllSys* = 0u32

  CtrlSrcReset* = 0u32
  CtrlSrcBits* = 1u32
  CtrlSrcMsb* = 0u32
  CtrlSrcLsb* = 0u32
  CtrlSrcAccess* = "RW"
  CtrlSrcValueClkRef* = 0u32
  CtrlSrcValueClksrcClkSysAux* = 1u32

  Khz* = 1000
  Mhz* = 1000000



{.push header: "hardware/clocks.h".}
proc getHz*(clkInd: ClockIndex): uint32 {.importc: "clock_get_hz".}
proc setReportedHz*(clkInd: ClockIndex, hz: cuint) {.importC: "clock_set_reported_hz".}
proc frequencyCountKhz*(src: cuint): uint32 {.importC: "frequency_count_khz".}
proc frequencyCountKhz*(src: Fc0SrcValue): uint32 {.importC: "frequency_count_khz".}
proc enableResus*(callBack: ResusCallback) {.importc: "clocks_enable_resus".}
proc clockConfigure*(clkInd: ClockIndex, src, auxSrc, srcFreq, freq: uint32): bool {.
    importC: "clock_configure".}
{.pop.}
