import ../helpers
{.passC: "-I" & picoSdkPath & "/src/rp2_common/hardware_resets/include".}
{.push header: "hardware/resets.h".}

let
  RESETS_RESET_USBCTRL_BITS* {.importc: "RESETS_RESET_USBCTRL_BITS".}: cuint
  RESETS_RESET_UART1_BITS* {.importc: "RESETS_RESET_UART1_BITS".}: cuint
  RESETS_RESET_UART0_BITS* {.importc: "RESETS_RESET_UART0_BITS".}: cuint
  RESETS_RESET_TIMER_BITS* {.importc: "RESETS_RESET_TIMER_BITS".}: cuint
  RESETS_RESET_TBMAN_BITS* {.importc: "RESETS_RESET_TBMAN_BITS".}: cuint
  RESETS_RESET_SYSINFO_BITS* {.importc: "RESETS_RESET_SYSINFO_BITS".}: cuint
  RESETS_RESET_SYSCFG_BITS* {.importc: "RESETS_RESET_SYSCFG_BITS".}: cuint
  RESETS_RESET_SPI1_BITS* {.importc: "RESETS_RESET_SPI1_BITS".}: cuint
  RESETS_RESET_SPI0_BITS* {.importc: "RESETS_RESET_SPI0_BITS".}: cuint
  RESETS_RESET_RTC_BITS* {.importc: "RESETS_RESET_RTC_BITS".}: cuint
  RESETS_RESET_PWM_BITS* {.importc: "RESETS_RESET_PWM_BITS".}: cuint
  RESETS_RESET_PLL_USB_BITS* {.importc: "RESETS_RESET_PLL_USB_BITS".}: cuint
  RESETS_RESET_PLL_SYS_BITS* {.importc: "RESETS_RESET_PLL_SYS_BITS".}: cuint
  RESETS_RESET_PIO1_BITS* {.importc: "RESETS_RESET_PIO1_BITS".}: cuint
  RESETS_RESET_PIO0_BITS* {.importc: "RESETS_RESET_PIO0_BITS".}: cuint
  RESETS_RESET_PADS_QSPI_BITS* {.importc: "RESETS_RESET_PADS_QSPI_BITS".}: cuint
  RESETS_RESET_PADS_BANK0_BITS* {.importc: "RESETS_RESET_PADS_BANK0_BITS".}: cuint
  RESETS_RESET_JTAG_BITS* {.importc: "RESETS_RESET_JTAG_BITS".}: cuint
  RESETS_RESET_IO_QSPI_BITS* {.importc: "RESETS_RESET_IO_QSPI_BITS".}: cuint
  RESETS_RESET_IO_BANK0_BITS* {.importc: "RESETS_RESET_IO_BANK0_BITS".}: cuint
  RESETS_RESET_I2C1_BITS* {.importc: "RESETS_RESET_I2C1_BITS".}: cuint
  RESETS_RESET_I2C0_BITS* {.importc: "RESETS_RESET_I2C0_BITS".}: cuint
  RESETS_RESET_DMA_BITS* {.importc: "RESETS_RESET_DMA_BITS".}: cuint
  RESETS_RESET_BUSCTRL_BITS* {.importc: "RESETS_RESET_BUSCTRL_BITS".}: cuint
  RESETS_RESET_ADC_BITS* {.importc: "RESETS_RESET_ADC_BITS".}: cuint

proc resetBlock*(bits: uint32) {.importc: "reset_block".}
  ## Reset the specified HW blocks
  ##
  ## \param bits Bit pattern indicating blocks to reset. See \ref reset_bitmask

proc unresetBlock*(bits: uint32) {.importc: "unreset_block".}
  ## Bring specified HW blocks out of reset
  ##
  ## \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask

proc unresetBlockWait*(bits: uint32) {.importc: "unreset_block_wait".}
  ## Bring specified HW blocks out of reset and wait for completion
  ##
  ## \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask

{.pop.}
