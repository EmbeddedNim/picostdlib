type
  GpioFunction* {.size: sizeof(uint32).} = enum
    XIP, SPI, UART, I2C, PWM, SIO, PIO0, PIO1, GPCK, USB, NULL
  Gpio* = distinct uint32
  Value* = distinct uint32

proc `==`*(a, b: Value): bool {.borrow.}
proc `==`*(a, b: Gpio): bool {.borrow.}
proc `$`*(a: Gpio): string {.borrow.}


const
  High* = 1.Value
  Low* = 0.Value
  In* = false
  Out* = true
  DefaultLedPin* = 25.Gpio

{.push header: "hardware/gpio.h".}

proc setFunction*(gpio: Gpio, fun: GpioFunction){.importC: "gpio_set_function".}

proc getFunction*(gpio: Gpio): GpioFunction {.importC: "gpio_get_function".}

proc pullDown*(gpio: Gpio) {.importC: "gpio_pull_down".}

proc pullUp*(gpio: Gpio) {.importC: "gpio_pull_up".}

proc disablePulls*(gpio: Gpio) {.importC: "gpio_disable_pulls".}

proc setOutever*(gpio: Gpio, value: Value) {.importC: "gpio_set_outover".}

proc setInover*(gpio: Gpio, value: Value) {.importC: "gpio_set_inover".}

proc setOever*(gpio: Gpio, value: Value) {.importC: "gpio_set_oever".}

proc init*(gpio: Gpio){.importC: "gpio_init".}

proc initMask*(gpioMask: Gpio) {.importC: "gpio_init_mask".}

proc get*(gpio: Gpio): Value {.importC: "gpio_get".}

proc getAll*: uint32 {.importC: "gpio_get_all".}

proc put*(gpio: Gpio, value: Value){.importC: "gpio_put".}

proc setDir*(gpio: Gpio, isOut: bool) {.importC: "gpio_set_dir".}

type
  IrqLevel* {.pure, importc: "enum gpio_irq_level", size: sizeof(cuint).} = enum
    low, high, fall, rise
  IrqCallback* {.importC: "gpio_irq_callback_t".} = proc(gpio: Gpio, evt: set[IrqLevel]){.cDecl.}

proc enableIrqWithCallback*(gpio: Gpio, events: set[IrqLevel], enabled: bool, event: IrqCallback){.
    importC: "gpio_set_irq_enabled_with_callback".}

{.pop.}

proc put*(gpio: Gpio, value: bool) =
  gpio.put(
    if value:
      High
    else:
      Low)
