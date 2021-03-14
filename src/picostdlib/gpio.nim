type 
  GpioFunction* {.size: sizeof(cint).}= enum
    XIP, SPI, UART, I2C, PWM, SIO, PIO0, PIO1, GPCK, USB, NULL
  Gpio* = distinct uint32
  Value* = distinct uint32

proc `==`*(a, b: Value): bool {.borrow.}
proc `==`*(a, b: Gpio): bool {.borrow.}

const 
  High* = 1.Value
  Low* = 0.Value
  In* = false
  Out* = true

{.push header: "hardware/gpio.h".}

proc setFunction*(gpio: Gpio, fun: GpioFunction){.importC:"gpio_set_function".}

proc getFunction*(gpio: Gpio): GpioFunction {.importC:"gpio_get_function".}

proc pullDown*(gpio: Gpio) {.importC:"gpio_pull_down".}

proc pullUp*(gpio: Gpio) {.importC:"gpio_pull_up".}

proc disablePulls*(gpio: Gpio) {.importC:"gpio_disable_pulls".}

proc setOutever*(gpio: Gpio, value: Value) {.importC:"gpio_set_outover".}

proc setInover*(gpio: Gpio, value: Value) {.importC:"gpio_set_inover".}

proc setOever*(gpio: Gpio, value: Value) {.importC:"gpio_set_oever".}

proc init*(gpio: Gpio){.importC:"gpio_init".}

proc initMask*(gpioMask: Gpio) {.importC:"gpio_init_mask".}

proc get*(gpio: Gpio): Value {.importC:"gpio_get".}

proc getAll*: uint32 {.importC:"gpio_get_all".}

proc put*(gpio: Gpio, value: Value){.importC: "gpio_put".}

proc setDir*(gpio: Gpio, isOut: bool) {.importC: "gpio_set_dir"}

{.pop.}

proc put*(gpio: Gpio, value: bool) = 
  gpio.put(
    if value:
      High
    else:
      Low)