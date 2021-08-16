import gpio

type AdcInput* {.pure, size: sizeof(cuint).} = enum
  Adc26 = 0, Adc27 = 1, Adc28 = 2, Adc29 = 3, AdcTemp = 4

const ThreePointThreeConv* = 3.3f / (1 shl 12)

{.push header:"hardware/adc.h".}
proc adcInit*{.importC:"adc_init".}

proc adcRead*: uint16 {.importC:"adc_read".}

proc initAdc*(gpio: Gpio){.importC: "adc_gpio_init".}

proc selectInput*(input: AdcInput){.importc: "adc_select_input".}

proc enableTempSensor*(enable: bool){.importc: "adc_set_temp_sensor_enabled".}


{.pop.}