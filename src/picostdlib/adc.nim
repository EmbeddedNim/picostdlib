import gpio

type AdcInput* {.pure, size: sizeof(cuint).} = enum
  ## Aliases for selectInput() procedure 
  ## ADC input. 0...3 are GPIOs 26...29 respectively. Input 4 is the onboard temperature sensor.
  Adc26 = 0, Adc27 = 1, Adc28 = 2, Adc29 = 3, AdcTemp = 4

const ThreePointThreeConv* = 3.3f / (1 shl 12)
  ## Useful for reading inputs from a 3.3v source

{.push header:"hardware/adc.h".}
proc adcInit*{.importC:"adc_init".}
  ## Initialise the ADC hardware

proc adcRead*: uint16 {.importC:"adc_read".}
 ## Performs a single ADC conversion, waits for the result, and then returns it.
 ## 
 ## **Returns:** Result of the conversion. 

proc initAdc*(gpio: Gpio){.importC: "adc_gpio_init".}
  ## Prepare a GPIO for use with ADC, by disabling all digital functions.
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    The GPIO number to use. Allowable GPIO numbers are 26 to 29 inclusive. 
  ## =========  ====== 

proc selectInput*(input: AdcInput){.importc: "adc_select_input".}
  ## ADC input select.
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **input**   ADC input. 0...3 are GPIOs 26...29 respectively. Input 4 is the onboard temperature sensor.
  ## =========  ====== 

proc enableTempSensor*(enable: bool){.importc: "adc_set_temp_sensor_enabled".}
  ## Enable the onboard temperature sensor. 
  ## 
  ## **Parameters:**
  ## 
  ## ===========  ====== 
  ## **enable**    Set true to power on the onboard temperature sensor, false to power off. 
  ## ===========  ====== 

{.pop.}