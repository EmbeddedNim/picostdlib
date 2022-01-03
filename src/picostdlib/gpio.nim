type
  GpioFunction* {.size: sizeof(uint32).} = enum
    ## GPIO function definitions for use with function select. 
    ## Each GPIO can have one function selected at a time. Likewise, 
    ## each peripheral input (e.g. UART0 RX) should only be selected on one 
    ## GPIO at a time. If the same peripheral input is connected to multiple 
    ## GPIOs, the peripheral sees the logical OR of these GPIO inputs.
    XIP, SPI, UART, I2C, PWM, SIO, PIO0, PIO1, GPCK, USB, NULL

  Gpio* = distinct range[0.uint32 .. 35.uint32]
    ## Gpio pins available to the RP2040. Not all pins may be available on some 
    ## microcontroller boards.
  Value* = distinct uint32
    ## Gpio function value. See datasheet.

proc `==`*(a, b: Value): bool {.borrow.}
proc `==`*(a, b: Gpio): bool {.borrow.}
proc `$`*(a: Gpio): string {.borrow.}


const
  High* = 1.Value
    ## Alias that is useful for put() procedure, or reading inputs.
  Low* = 0.Value
    ## Alias that is useful for put() procedure, or reading inputs.
  In* = false
    ## Alias that is useful for setDir() procedure
  Out* = true
    ## Alias that is useful for setDir() procedure
  DefaultLedPin* = 25.Gpio
    ## constant variable for the on-board LED

{.push header: "hardware/gpio.h".}

proc setFunction*(gpio: Gpio, fun: GpioFunction){.importC: "gpio_set_function".}
  ## Select GPIO function. 
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number
  ## **fn**      GpioFunction: XIP, SPI, UART, I2C, PWM, SIO, PIO0, PIO1, GPCK, USB, NULL

proc getFunction*(gpio: Gpio): GpioFunction {.importC: "gpio_get_function".}
  ## Returns a Gpio function
  ## 
  ## **Parameters:**
  ## 
  ## =========   ====== 
  ## **gpio**    Gpio number
  ## =========   ======
  ## 
  ## **Returns:** GpioFunction: XIP, SPI, UART, I2C, PWM, SIO, PIO0, PIO1, GPCK, USB, NULL
  ## 

proc pullDown*(gpio: Gpio) {.importC: "gpio_pull_down".}
  ## Set specified Gpio to be pulled down. 
  ## 
  ## **Parameters:**
  ## 
  ## =========   ====== 
  ## **gpio**    Gpio number

proc pullUp*(gpio: Gpio) {.importC: "gpio_pull_up".}
  ## Set specified Gpio to be pulled up. 
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number

proc disablePulls*(gpio: Gpio) {.importC: "gpio_disable_pulls".}
  ## Disable pulls on specified Gpio. 
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number

proc setOutever*(gpio: Gpio, value: Value) {.importC: "gpio_set_outover".}
  ## Set Gpio output override. 

proc setInover*(gpio: Gpio, value: Value) {.importC: "gpio_set_inover".}
  ## Set Gpio input override. 

proc setOever*(gpio: Gpio, value: Value) {.importC: "gpio_set_oever".}

proc init*(gpio: Gpio){.importC: "gpio_init".}
  ## Initialise a Gpio for (enabled I/O and set func to Gpio_FUNC_SIO) 
  ## Clear the output enable (i.e. set to input) Clear any output value.
  ##
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number

proc initMask*(gpioMask: Gpio) {.importC: "gpio_init_mask".}
  ## Initialise multiple Gpios (enabled I/O and set func to Gpio_FUNC_SIO).
  ## Clear the output enable (i.e. set to input) Clear any output value.
  ##
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **gpioMask**      Mask with 1 bit per Gpio number to initialize 

proc get*(gpio: Gpio): Value {.importC: "gpio_get".}
  ## Get state of a single specified Gpio. 
  ## 
  ## **Returns:** Current state of the Gpio. Low (0.Value) or High (1.Value)
  

proc getAll*: uint32 {.importC: "gpio_get_all".}
  ## Get raw value of all Gpios. 
  ## 
  ## **Returns:** uint32 of raw Gpio values, as bits 0-29  

proc put*(gpio: Gpio, value: Value){.importC: "gpio_put".}
  ## Drive a single Gpio high/low. 
  ## 
  ## **Parameters:**
  ## 
  ## =======================================  ====== 
  ## **gpio**                                 Gpio number
  ## **High**, **Low**, **true**, **false**   High or true sets output, otherwise clears Gpio

proc setDir*(gpio: Gpio, isOut: bool) {.importC: "gpio_set_dir".}
  ## Set a single Gpio direction. 
  ## 
  ## **Parameters:**
  ## 
  ## =====================================  ====== 
  ## **gpio**                               Gpio number
  ## **In**, **Out**, **true**, **false**   true or Output for output; In or false for input

type
  IrqLevel* {.pure, importc: "enum gpio_irq_level", size: sizeof(cuint).} = enum
    ## GPIO Interrupt level definitions. 
    ## 
    ## An interrupt can be generated for every GPIO pin in 4 scenarios:
    ## 
    ## ===========  ====== 
    ## **low**       the GPIO pin is a logical 0
    ## **high**      the GPIO pin is a logical 1
    ## **fall**      the GPIO has transitioned from a logical 1 to a logical 0
    ## **rise**      the GPIO has transitioned from a logical 0 to a logical 1
    ## ===========  ====== 
    ##
    ## The level interrupts are not latched. This means that if the pin is a 
    ## logical 1 and the level high interrupt is active, it will become 
    ## inactive as soon as the pin changes to a logical 0. The edge interrupts 
    ## are stored in the INTR register and can be cleared by writing to the 
    ## INTR register. 
    low, high, fall, rise
    
  IrqCallback* {.importC: "gpio_irq_callback_t".} = proc(gpio: Gpio, evt: set[IrqLevel]){.cDecl.}

proc enableIrq*(gpio: Gpio, events: set[IrqLevel], enabled: bool){.importC: "gpio_set_irq_enabled".}
  ## Enable or disable interrupts for specified GPIO. 
  ## 
  ## **Parameters:**
  ## 
  ## ==============  ====== 
  ## **gpio**        Gpio number to be monitored for event
  ## **event**       Which events will cause an interrupt 
  ## **enabled**     Enable or disable flag for turning on and off the interupt


proc enableIrqWithCallback*(gpio: Gpio, events: set[IrqLevel], enabled: bool, event: IrqCallback){.
    importC: "gpio_set_irq_enabled_with_callback".}

{.pop.}

proc put*(gpio: Gpio, value: bool) =
  gpio.put(
    if value:
      High
    else:
      Low)

template setupGpio*(name: untyped, pin: Gpio, dir: bool) =
  # Makes a `const 'name' = pin; init(name); name.setDir(dir)
  const name = pin
  init(name)
  setDir(name, dir)
  
proc init*( _ : typedesc[Gpio], pin: range[0 .. 35], dir = Out): Gpio =
  result = pin.Gpio
  result.init() 
  result.setDir(dir) 
