
{.push header: "hardware/structs/clocks.h".}
type
  ClockIndex* {.pure, importC: "enum clock_index".} = enum
    ## hardware clock identifiers
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
  ## Get the current frequency of the specified clock. 
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **clkInd**    clock
  ## ============  ====== 
  ## 
  ## **Returns:** Clock frequency in Hz 

proc setReportedHz*(clkInd: ClockIndex, hz: cuint) {.importC: "clock_set_reported_hz".}
  ## Set the "current frequency" of the clock as reported by clock_get_hz 
  ## without actually changing the clock.
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **clkInd**     clock
  ## **hz**         frequency in hz to set the new reporting value of the clock
  ## ============  ====== 

proc frequencyCountKhz*(src: cuint): uint32 {.importC: "frequency_count_khz".}
  ## Measure a clocks frequency using the Frequency counter. 
  ## 
  ## Uses the inbuilt frequency counter to measure the specified clocks 
  ## frequency. Currently, this function is accurate to +-1KHz. See the 
  ## datasheet for more details. 
  ## 
proc frequencyCountKhz*(src: Fc0SrcValue): uint32 {.importC: "frequency_count_khz".}
  ## Measure a clocks frequency using the Frequency counter. 
  ## 
  ## Uses the inbuilt frequency counter to measure the specified clocks 
  ## frequency. Currently, this function is accurate to +-1KHz. See the 
  ## datasheet for more details. 
  ## 
proc enableResus*(callBack: ResusCallback) {.importc: "clocks_enable_resus".}
  ## Enable the resus function. Restarts clk_sys if it is accidentally stopped. 
  ## 
  ## The resuscitate function will restart the system clock if it falls below a 
  ## certain speed (or stops). This could happen if the clock source the system 
  ## clock is running from stops. For example if a PLL is stopped.
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **callBack**   a function pointer provided by the user to call if a resus event happens. 
  ## ============  ======
proc clockConfigure*(clkInd: ClockIndex, src, auxSrc, srcFreq, freq: uint32): bool {.
    importC: "clock_configure".}
  ## Configure the specified clock. 
  ## 
  ## See the tables in the adc module description for details on the possible 
  ## values for clock sources.
  ## 
{.pop.}
