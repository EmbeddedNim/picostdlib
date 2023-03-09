import ../regs/clocks
export clocks

{.push header: "hardware/structs/clocks.h".}

type
  ClockIndex* {.pure, importc: "enum clock_index".} = enum
    ## Enumeration identifying a hardware clock
    GpOut0  ## GPIO Muxing 0
    GpOut1  ## GPIO Muxing 1
    GpOut2  ## GPIO Muxing 2
    GpOut3  ## GPIO Muxing 3
    Ref     ## Watchdog and timers reference clock
    Sys     ## Processors, bus fabric, memory, memory mapped registers
    Peri    ## Peripheral clock for UART and SPI
    Usb     ## USB clock
    Adc     ## ADC clock
    Rtc     ## Real Time Clock
    ClkCount

{.pop.}
