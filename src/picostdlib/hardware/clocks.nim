import ./regs/clocks
import ./gpio
export clocks

type
  ClockIndex* {.pure, size: sizeof(cuint).} = enum
    ## Enumeration identifying a hardware clock
    GpOut0  # GPIO Muxing 0
    GpOut1  # GPIO Muxing 1
    GpOut2  # GPIO Muxing 2
    GpOut3  # GPIO Muxing 3
    Ref   # Watchdog and timers reference clock
    Sys     # Processors, bus fabric, memory, memory mapped registers
    Peri    # Peripheral clock for UART and SPI
    Usb     # USB clock
    Adc     # ADC clock
    Rtc     # Real Time Clock


type
  ResusCallback* {.importc: "resus_callback_t".} = proc () {.cdecl.}

const
  KHz* = 1000
  MHz* = 1000000

{.push header: "hardware/clocks.h".}

proc clocksInit*() {.importc: "clocks_init".}
  ## Initialise the clock hardware
  ## 
  ## Must be called before any other clock function.

proc clockConfigure*(clkInd: ClockIndex, src, auxSrc, srcFreq, freq: uint32): bool {.importc: "clock_configure".}
  ## Configure the specified clock. 
  ## 
  ## See the tables in the description for details on the possible values for clock sources.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **clkInd**     The clock to configure
  ## **src**        The main clock source, can be 0.
  ## **auxSrc**     The auxiliary clock source, which depends on which clock is being set. Can be 0
  ## **srcFreq**    Frequency of the input clock source
  ## **freq**       Requested frequency
  ## =============  ====== 

proc clockStop*(clkInd: ClockIndex) {.importc: "clock_stop".}
  ## Stop the specified clock
  ## 
  ## **Parameters:**
  ## 
  ## ===========  ====== 
  ## **clkInd**    The clock to stop
  ## ===========  ====== 

proc clockGetHz*(clkInd: ClockIndex): uint32 {.importc: "clock_get_hz".}
  ## Get the current frequency of the specified clock
  ## 
  ## **Parameters:**
  ## 
  ## ===========  ====== 
  ## **clkInd**    Clock
  ## ===========  ====== 
  ## 
  ## **Returns:** Clock frequency in Hz


proc frequencyCountKHz*(src: ClocksFc0Src): uint32 {.importc: "frequency_count_khz".}
  ## Measure a clocks frequency using the Frequency counter.
  ## 
  ## Uses the inbuilt frequency counter to measure the specified clocks frequency.
  ## Currently, this function is accurate to +-1KHz. See the datasheet for more details.

proc clockSetReportedHz*(clkInd: ClockIndex, hz: cuint) {.importc: "clock_set_reported_hz".}
  ## Set the "current frequency" of the clock as reported by clock_get_hz without actually changing the clock
  ## 
  ## **Parameters:**
  ## 
  ## ===========  ====== 
  ## **clkInd**    Clock
  ## **hz**        frequency in hz to set the new reporting value of the clock
  ## ===========  ====== 

proc clocksEnableResus*(resusCallback: ResusCallback) {.importc: "clocks_enable_resus".}
  ## Enable the resus function. Restarts clk_sys if it is accidentally stopped.
  ## 
  ## The resuscitate function will restart the system clock if it falls below a certain speed (or stops). This
  ## could happen if the clock source the system clock is running from stops. For example if a PLL is stopped.
  ## 
  ## **Parameters:**
  ## 
  ## ==================  ====== 
  ## **resusCallback**    a function pointer provided by the user to call if a resus event happens.
  ## ==================  ======

proc clockGpioInitIntFrac*(gpio: Gpio; src: ClocksClkGpoutCtrlAuxSrc; divInt: uint32; divFrac: uint8) {.importc: "clock_gpio_init_int_frac".}
  ## \brief Output an optionally divided clock to the specified gpio pin.
  ## \ingroup hardware_clocks
  ##
  ## \param gpio The GPIO pin to output the clock to. Valid GPIOs are: 21, 23, 24, 25. These GPIOs are connected to the GPOUT0-3 clock generators.
  ## \param src  The source clock. See the register field CLOCKS_CLK_GPOUT0_CTRL_AUXSRC for a full list. The list is the same for each GPOUT clock generator.
  ## \param div_int  The integer part of the value to divide the source clock by. This is useful to not overwhelm the GPIO pin with a fast clock. this is in range of 1..2^24-1.
  ## \param div_frac The fractional part of the value to divide the source clock by. This is in range of 0..255 (/256).

proc clockGpioInit*(gpio: Gpio; src: ClocksClkGpoutCtrlAuxSrc; `div`: cfloat) {.importc: "clock_gpio_init".}
  ## Output an optionally divided clock to the specified gpio pin.
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    The GPIO pin to output the clock to. Valid GPIOs are: 21, 23, 24, 25. These GPIOs are connected to the GPOUT0-3 clock generators.
  ## **src**     The source clock. See the register field CLOCKS_CLK_GPOUT0_CTRL_AUXSRC for a full list. The list is the same for each GPOUT clock generator.
  ## **div**     The amount to divide the source clock by. This is useful to not overwhelm the GPIO pin with a fast clock.
  ## =========  ====== 

proc clockConfigureGpin*(clkInd: ClockIndex, gpio: Gpio, srcFreq, freq: uint32): bool {.importc: "clock_configure_gpin".}
  ## Configure a clock to come from a gpio input
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **clkInd**     The clock to configure
  ## **gpio**       The GPIO pin to run the clock from. Valid GPIOs are: 20 and 22.
  ## **srcFreq**    Frequency of the input clock source
  ## **freq**       Requested frequency
  ## ============  ====== 

{.pop.}
