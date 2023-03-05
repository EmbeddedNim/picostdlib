type
  ClocksFc0Src* {.pure.} = enum
    ## Clock sent to frequency counter, set to 0 when not required.
    ## Writing to this register initiates the frequency count
    Null
    PllSysClksrcPrimary
    PllUsbClksrcPrimary
    RoscClksrc
    RoscClksrcPh
    XoscClksrc
    ClksrcGpin0
    ClksrcGpin1
    ClkRef
    ClkSys
    ClkPeri
    ClkUsb
    ClkAdc
    ClkRtc

  ClocksClkGpoutCtrlAuxSrc* {.pure.} = enum
    ## Selects the auxiliary clock source, will glitch when switching
    ClksrcPllSys
    ClksrcGpin0
    ClksrcGpin1
    ClksrcPllUsb
    RoscClksrc
    XoscClksrc
    ClkSys
    ClkUsb
    ClkAdc
    ClkRtc
    ClkRef

  ClocksClkSysCtrlAuxSrc* {.pure.} = enum
    ## Selects the auxiliary clock source, will glitch when switching
    ClksrcPllSys
    ClksrcPllUsb
    RoscClksrc
    XoscClksrc
    ClksrcGpin0
    ClksrcGpin1

const
  Fc0SrcOffset* = 0x00000094'u32
  Fc0SrcBits* = 0x000000ff'u32
  Fc0SrcReset* = 0x00000000'u32
  Fc0SrcMsb* = 7'u32
  Fc0SrcLsb* = 0'u32
  Fc0SrcAccess* = "RW"
  Fc0SrcValueNull* = 0x00'u32

  CtrlAuxsrcReset* = 0'u32
  CtrlAuxsrcBits* = 0xe0'u32
  CtrlAuxsrcMsb* = 7'u32
  CtrlAuxsrcLsb* = 0'u32
  CtrlAuxsrcAccess* = "RW"
  CtrlAuxsrcValueClksrcPllSys* = 0'u32

  CtrlSrcReset* = 0'u32
  CtrlSrcBits* = 1'u32
  CtrlSrcMsb* = 0'u32
  CtrlSrcLsb* = 0'u32
  CtrlSrcAccess* = "RW"
  CtrlSrcValueClkRef* = 0'u32
  CtrlSrcValueClksrcClkSysAux* = 1'u32
