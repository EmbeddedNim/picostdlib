import ./hardware/gpio
export gpio

{.push header: "pico.h".}

let
  # Uart
  PicoDefaultUart* {.importc: "PICO_DEFAULT_UART".}: cuint
  PicoDefaultUartTxPin* {.importc: "PICO_DEFAULT_UART_TX_PIN".}: Gpio
  PicoDefaultUartRxPin* {.importc: "PICO_DEFAULT_UART_RX_PIN".}: Gpio

  # Led
  PicoDefaultLedPin* {.importc: "PICO_DEFAULT_LED_PIN".}: Gpio
  PicoDefaultWs2812Pin* {.importc: "PICO_DEFAULT_WS2812_PIN".}: Gpio

  # I2c
  PicoDefaultI2c* {.importc: "PICO_DEFAULT_I2C".}: cuint
  PicoDefaultI2cSdaPin* {.importc: "PICO_DEFAULT_I2C_SDA_PIN".}: Gpio
  PicoDefaultI2cSclPin* {.importc: "PICO_DEFAULT_I2C_SCL_PIN".}: Gpio

  # Spi
  PicoDefaultSpi* {.importc: "PICO_DEFAULT_SPI".}: cuint
  PicoDefaultSpiSckPin* {.importc: "PICO_DEFAULT_SPI_SCK_PIN".}: Gpio
  PicoDefaultSpiTxPin* {.importc: "PICO_DEFAULT_SPI_TX_PIN".}: Gpio
  PicoDefaultSpiRxPin* {.importc: "PICO_DEFAULT_SPI_RX_PIN".}: Gpio
  PicoDefaultSpiCsnPin* {.importc: "PICO_DEFAULT_SPI_CSN_PIN".}: Gpio

  # Flash
  PicoBootStage2ChooseW25Q080* {.importc: "PICO_BOOT_STAGE2_CHOOSE_W25Q080".}: bool
  PicoBootStage2ChooseGeneric03H* {.importc: "PICO_BOOT_STAGE2_CHOOSE_GENERIC_03H".}: bool
  PicoFlashSpiClkdiv* {.importc: "PICO_FLASH_SPI_CLKDIV".}: cuint
  PicoFlashSizeBytes* {.importc: "PICO_FLASH_SIZE_BYTES".}: cuint

  PicoSmpsModePin* {.importc: "PICO_SMPS_MODE_PIN".}: Gpio
  PicoRP2040B0Supported* {.importc: "PICO_RP2040_B0_SUPPORTED".}: bool
  PicoRP2040B1Supported* {.importc: "PICO_RP2040_B1_SUPPORTED".}: bool

  PicoVbusPin* {.importc: "PICO_VBUS_PIN".}: Gpio
  PicoVsysPin* {.importc: "PICO_VSYS_PIN".}: Gpio

  # Cyw43
  Cyw43PinWlHostWake* {.importc: "CYW43_PIN_WL_HOST_WAKE".}: Gpio
  Cyw43PinWlRegOn* {.importc: "CYW43_PIN_WL_REG_ON".}: Gpio
  Cyw43WlGpioCount* {.importc: "CYW43_WL_GPIO_COUNT".}: cuint
  Cyw43WlGpioLedPin* {.importc: "CYW43_WL_GPIO_LED_PIN".}: Cyw43WlGpio
  Cyw43WlGpioVbusPin* {.importc: "CYW43_WL_GPIO_VBUS_PIN".}: Cyw43WlGpio
  Cyw43UsesVsysPin* {.importc: "CYW43_USES_VSYS_PIN".}: bool

{.pop.}
