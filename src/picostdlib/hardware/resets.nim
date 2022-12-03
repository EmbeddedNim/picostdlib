{.push header:"hardware/resets.h".}

proc resetBlock*(bits: uint32) {.importc: "reset_block".}
  ## ```
  ##   \file hardware/resets.h
  ##     \defgroup hardware_resets hardware_resets
  ##   
  ##    Hardware Reset API
  ##   
  ##    The reset controller allows software control of the resets to all of the peripherals that are not
  ##    critical to boot the processor in the RP2040.
  ##   
  ##    \subsubsection reset_bitmask
  ##    \addtogroup hardware_resets
  ##   
  ##    Multiple blocks are referred to using a bitmask as follows:
  ##   
  ##    Block to reset | Bit
  ##    ---------------|----
  ##    USB | 24
  ##    UART 1 | 23
  ##    UART 0 | 22
  ##    Timer | 21
  ##    TB Manager | 20
  ##    SysInfo | 19
  ##    System Config | 18
  ##    SPI 1 | 17
  ##    SPI 0 | 16
  ##    RTC | 15
  ##    PWM | 14
  ##    PLL USB | 13
  ##    PLL System | 12
  ##    PIO 1 | 11
  ##    PIO 0 | 10
  ##    Pads - QSPI | 9
  ##    Pads - bank 0 | 8
  ##    JTAG | 7
  ##    IO Bank 1 | 6
  ##    IO Bank 0 | 5
  ##    I2C 1 | 4
  ##    I2C 0 | 3
  ##    DMA | 2
  ##    Bus Control | 1
  ##    ADC 0 | 0
  ##   
  ##    \subsection reset_example Example
  ##    \addtogroup hardware_resets
  ##    \include hello_reset.c
  ##    
  ##     / \tag::reset_funcs[]
  ##     ! \brief Reset the specified HW blocks
  ##     \ingroup hardware_resets
  ##   
  ##    \param bits Bit pattern indicating blocks to reset. See \ref reset_bitmask
  ## ```

proc unresetBlock*(bits: uint32) {.importc: "unreset_block".}
  ## ```
  ##   ! \brief bring specified HW blocks out of reset
  ##     \ingroup hardware_resets
  ##   
  ##    \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask
  ## ```

proc unresetBlockWait*(bits: uint32) {.importc: "unreset_block_wait".}
  ## ```
  ##   ! \brief Bring specified HW blocks out of reset and wait for completion
  ##     \ingroup hardware_resets
  ##   
  ##    \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask
  ## ```

{.pop.}
