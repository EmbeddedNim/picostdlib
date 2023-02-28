import ./irq

type
  GpioFunction* {.pure, size: sizeof(uint8), importc: "enum gpio_function".} = enum
    ## GPIO function definitions for use with function select. 
    ## Each GPIO can have one function selected at a time. Likewise, 
    ## each peripheral input (e.g. UART0 RX) should only be selected on one 
    ## GPIO at a time. If the same peripheral input is connected to multiple 
    ## GPIOs, the peripheral sees the logical OR of these GPIO inputs.
    Xip, Spi, Uart, I2c, Pwm, Sio, Pio0, Pio1, Gpck, Usb,
    Null = 0x1F

  Gpio* = distinct range[0.cuint .. 35.cuint]
    ## Gpio pins available to the RP2040. Not all pins may be available on some 
    ## microcontroller boards.

  Value* = distinct bool
    ## Gpio function value. See datasheet.
  
  GpioOverride* {.pure, size: sizeof(cuint).} = enum
    Normal  # peripheral signal selected via \ref gpio_set_function
    Invert  # invert peripheral signal selected via \ref gpio_set_function
    Low     # drive low/disable output
    High     # drive high/enable output

  GpioSlewRate* {.pure, size: sizeof(cuint).} = enum
    Slow  # Slew rate limiting enabled
    Fast   # Slew rate limiting disabled
  
  GpioDriveStrength* {.pure, size: sizeof(cuint).} = enum
    mA_2  # 2 mA nominal drive strength
    mA_4  # 4 mA nominal drive strength
    mA_8  # 2 mA nominal drive strength
    mA_12  # 12 mA nominal drive strength
  
  GpioIrqLevel* {.pure, size: sizeof(cuint).} = enum
    Low = 0x1'u
    High = 0x2'u
    EdgeFall = 0x4'u
    EdgeRise = 0x8'u

{.push header: "hardware/gpio.h".}

type
  GpioIrqCallback* {.importc: "gpio_irq_callback_t".} = proc (gpio: Gpio; eventMask: set[GpioIrqLevel]) {.cdecl.}

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

proc gpioSetFunction*(gpio: Gpio, fn: GpioFunction) {.importc: "gpio_set_function".}
  ## Select GPIO function. 
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number
  ## **fn**      GpioFunction: XIP, SPI, UART, I2C, PWM, SIO, PIO0, PIO1, GPCK, USB, NULL

proc gpioGetFunction*(gpio: Gpio): GpioFunction {.importc: "gpio_get_function".}
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

proc gpioSetPulls*(gpio: Gpio; up: bool; down: bool) {.importc: "gpio_set_pulls".}
  ## ```
  ##   ! \brief Select up and down pulls on specific GPIO
  ##     \ingroup hardware_gpio
  ## 
  ##    \param gpio GPIO number
  ##    \param up If true set a pull up on the GPIO
  ##    \param down If true set a pull down on the GPIO
  ## 
  ##    \note On the RP2040, setting both pulls enables a "bus keep" function,
  ##    i.e. a weak pull to whatever is current high/low state of GPIO.
  ## ```

proc gpioPullUp*(gpio: Gpio) {.importc: "gpio_pull_up".}
  ## Set specified Gpio to be pulled up. 
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number

proc gpioIsPulledUp*(gpio: Gpio): bool {.importc: "gpio_is_pulled_up".}
  ## ```
  ##   ! \brief Determine if the specified GPIO is pulled up.
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \return true if the GPIO is pulled up
  ## ```

proc gpioPullDown*(gpio: Gpio) {.importc: "gpio_pull_down".}
  ## Set specified Gpio to be pulled down. 
  ## 
  ## **Parameters:**
  ## 
  ## =========   ====== 
  ## **gpio**    Gpio number

proc gpioIsPulledDown*(gpio: Gpio): bool {.importc: "gpio_is_pulled_down".}
  ## ```
  ##   ! \brief Determine if the specified GPIO is pulled down.
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \return true if the GPIO is pulled down
  ## ```

proc gpioDisablePulls*(gpio: Gpio) {.importc: "gpio_disable_pulls".}
  ## Disable pulls on specified GPIO
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number

proc gpioSetIrqover*(gpio: Gpio; value: GpioOverride) {.importc: "gpio_set_irqover".}
  ## ```
  ##   ! \brief Set GPIO IRQ override
  ##     \ingroup hardware_gpio
  ##   
  ##    Optionally invert a GPIO IRQ signal, or drive it high or low
  ##   
  ##    \param gpio GPIO number
  ##    \param value See \ref gpio_override
  ## ```

proc gpioSetOutever*(gpio: Gpio, value: GpioOverride) {.importc: "gpio_set_outover".}
  ## ```
  ##   ! \brief Set GPIO output override
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \param value See \ref gpio_override
  ## ```

proc gpioSetInover*(gpio: Gpio, value: GpioOverride) {.importc: "gpio_set_inover".}
  ## ```
  ##   ! \brief Select GPIO input override
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \param value See \ref gpio_override
  ## ```

proc gpioSetOeover*(gpio: Gpio, value: GpioOverride) {.importc: "gpio_set_oeover".}
  ## ```
  ##   ! \brief Select GPIO output enable override
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \param value See \ref gpio_override
  ## ```

proc gpioSetInputEnabled*(gpio: Gpio; enabled: bool) {.importc: "gpio_set_input_enabled".}
  ## ```
  ##   ! \brief Enable GPIO input
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \param enabled true to enable input on specified GPIO
  ## ```

proc gpioSetInputHysteresisEnabled*(gpio: Gpio; enabled: bool) {.importc: "gpio_set_input_hysteresis_enabled".}
  ## ```
  ##   ! \brief Enable/disable GPIO input hysteresis (Schmitt trigger)
  ##     \ingroup hardware_gpio
  ##   
  ##    Enable or disable the Schmitt trigger hysteresis on a given GPIO. This is
  ##    enabled on all GPIOs by default. Disabling input hysteresis can lead to
  ##    inconsistent readings when the input signal has very long rise or fall
  ##    times, but slightly reduces the GPIO's input delay.
  ##   
  ##    \sa gpio_is_input_hysteresis_enabled
  ##    \param gpio GPIO number
  ##    \param enabled true to enable input hysteresis on specified GPIO
  ## ```

proc gpioIsInputHysteresisEnabled*(gpio: Gpio): bool {.importc: "gpio_is_input_hysteresis_enabled".}
  ## ```
  ##   ! \brief Determine whether input hysteresis is enabled on a specified GPIO
  ##     \ingroup hardware_gpio
  ## 
  ##    \sa gpio_set_input_hysteresis_enabled
  ##    \param gpio GPIO number
  ## ```

proc gpioSetSlewRate*(gpio: Gpio; slew: GpioSlewRate) {.importc: "gpio_set_slew_rate".}
  ## ```
  ##   ! \brief Set slew rate for a specified GPIO
  ##     \ingroup hardware_gpio
  ##   
  ##    \sa gpio_get_slew_rate
  ##    \param gpio GPIO number
  ##    \param slew GPIO output slew rate
  ## ```

proc gpioGetSlewRate*(gpio: Gpio): GpioSlewRate {.importc: "gpio_get_slew_rate".}
  ## ```
  ##   ! \brief Determine current slew rate for a specified GPIO
  ##     \ingroup hardware_gpio
  ##   
  ##    \sa gpio_set_slew_rate
  ##    \param gpio GPIO number
  ##    \return Current slew rate of that GPIO
  ## ```

proc gpioSetDriveStrength*(gpio: Gpio; drive: GpioDriveStrength) {.importc: "gpio_set_drive_strength".}
  ## ```
  ##   ! \brief Set drive strength for a specified GPIO
  ##     \ingroup hardware_gpio
  ##   
  ##    \sa gpio_get_drive_strength
  ##    \param gpio GPIO number
  ##    \param drive GPIO output drive strength
  ## ```

proc gpioGetDriveStrength*(gpio: Gpio): GpioDriveStrength {.importc: "gpio_get_drive_strength".}
  ## ```
  ##   ! \brief Determine current drive strength for a specified GPIO
  ##     \ingroup hardware_gpio
  ##   
  ##    \sa gpio_set_drive_strength
  ##    \param gpio GPIO number
  ##    \return Current drive strength of that GPIO
  ## ```

proc gpioSetIrqEnabled*(gpio: Gpio; eventMask: set[GpioIrqLevel]; enabled: bool) {.importc: "gpio_set_irq_enabled".}
  ## ```
  ##   ! \brief Enable or disable specific interrupt events for specified GPIO
  ##     \ingroup hardware_gpio
  ##   
  ##    This function sets which GPIO events cause a GPIO interrupt on the calling core. See
  ##    \ref gpio_set_irq_callback, \ref gpio_set_irq_enabled_with_callback and
  ##    \ref gpio_add_raw_irq_handler to set up a GPIO interrupt handler to handle the events.
  ##   
  ##    \note The IO IRQs are independent per-processor. This configures the interrupt events for
  ##    the processor that calls the function.
  ##   
  ##    \param gpio GPIO number
  ##    \param event_mask Which events will cause an interrupt
  ##    \param enabled Enable or disable flag
  ##   
  ##    Events is a bitmask of the following \ref gpio_irq_level values:
  ##   
  ##    bit | constant            | interrupt
  ##    ----|----------------------------------------------------------
  ##      0 | GPIO_IRQ_LEVEL_LOW  | Continuously while level is low
  ##      1 | GPIO_IRQ_LEVEL_HIGH | Continuously while level is high
  ##      2 | GPIO_IRQ_EDGE_FALL  | On each transition from high to low
  ##      3 | GPIO_IRQ_EDGE_RISE  | On each transition from low to high
  ##   
  ##    which are specified in \ref gpio_irq_level
  ## ```

proc gpioSetIrqCallback*(callback: GpioIrqCallback) {.importc: "gpio_set_irq_callback".}
  ## ```
  ##   ! \brief Set the generic callback used for GPIO IRQ events for the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    This function sets the callback used for all GPIO IRQs on the current core that are not explicitly
  ##    hooked via \ref gpio_add_raw_irq_handler or other gpio_add_raw_irq_handler_ functions.
  ##   
  ##    This function is called with the GPIO number and event mask for each of the (not explicitly hooked)
  ##    GPIOs that have events enabled and that are pending (see \ref gpio_get_irq_event_mask).
  ##   
  ##    \note The IO IRQs are independent per-processor. This function affects
  ##    the processor that calls the function.
  ##   
  ##    \param callback default user function to call on GPIO irq. Note only one of these can be set per processor.
  ## ```

proc gpioSetIrqEnabledWithCallback*(gpio: Gpio; eventMask: set[GpioIrqLevel]; enabled: bool; callback: GpioIrqCallback) {.importc: "gpio_set_irq_enabled_with_callback".}
  ## ```
  ##   ! \brief Convenience function which performs multiple GPIO IRQ related initializations
  ##     \ingroup hardware_gpio
  ##   
  ##    This method is a slightly eclectic mix of initialization, that:
  ##   
  ##    \li Updates whether the specified events for the specified GPIO causes an interrupt on the calling core based
  ##    on the enable flag.
  ##   
  ##    \li Sets the callback handler for the calling core to callback (or clears the handler if the callback is NULL).
  ##   
  ##    \li Enables GPIO IRQs on the current core if enabled is true.
  ##   
  ##    This method is commonly used to perform a one time setup, and following that any additional IRQs/events are enabled
  ##    via \ref gpio_set_irq_enabled. All GPIOs/events added in this way on the same core share the same callback; for multiple
  ##    independent handlers for different GPIOs you should use \ref gpio_add_raw_irq_handler and related functions.
  ##   
  ##    This method is equivalent to:
  ##   
  ##    \code{.c}
  ##    gpio_set_irq_enabled(gpio, event_mask, enabled);
  ##    gpio_set_irq_callback(callback);
  ##    if (enabled) irq_set_enabled(IO_IRQ_BANK0, true);
  ##    \endcode
  ##   
  ##    \note The IO IRQs are independent per-processor. This method affects only the processor that calls the function.
  ##   
  ##    \param gpio GPIO number
  ##    \param event_mask Which events will cause an interrupt. See \ref gpio_irq_level for details.
  ##    \param enabled Enable or disable flag
  ##    \param callback user function to call on GPIO irq. if NULL, the callback is removed
  ## ```

proc gpioSetDormantIrqEnabled*(gpio: Gpio; eventMask: set[GpioIrqLevel]; enabled: bool) {.importc: "gpio_set_dormant_irq_enabled".}
  ## ```
  ##   ! \brief Enable dormant wake up interrupt for specified GPIO and events
  ##     \ingroup hardware_gpio
  ##   
  ##    This configures IRQs to restart the XOSC or ROSC when they are
  ##    disabled in dormant mode
  ##   
  ##    \param gpio GPIO number
  ##    \param event_mask Which events will cause an interrupt. See \ref gpio_irq_level for details.
  ##    \param enabled Enable/disable flag
  ## ```

proc gpioGetIrqEventMask*(gpio: Gpio): set[GpioIrqLevel] {.importc: "gpio_get_irq_event_mask".}
  ## ```
  ##   ! \brief Return the current interrupt status (pending events) for the given GPIO
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \return Bitmask of events that are currently pending for the GPIO. See \ref gpio_irq_level for details.
  ##    \sa gpio_acknowledge_irq
  ## ```

proc gpioAcknowledgeIrq*(gpio: Gpio; eventMask: set[GpioIrqLevel]) {.importc: "gpio_acknowledge_irq".}
  ## ```
  ##   ! \brief Acknowledge a GPIO interrupt for the specified events on the calling core
  ##     \ingroup hardware_gpio
  ##   
  ##    \note This may be called with a mask of any of valid bits specified in \ref gpio_irq_level, however
  ##    it has no effect on \a level sensitive interrupts which remain pending while the GPIO is at the specified
  ##    level. When handling \a level sensitive interrupts, you should generally disable the interrupt (see
  ##    \ref gpio_set_irq_enabled) and then set it up again later once the GPIO level has changed (or to catch
  ##    the opposite level).
  ##   
  ##    \param gpio GPIO number
  ##    \param events Bitmask of events to clear. See \ref gpio_set_irq_enabled for details.
  ##   
  ##    \note For callbacks set with \ref gpio_set_irq_enabled_with_callback, or \ref gpio_set_irq_callback, this function is called automatically.
  ##    \param event_mask Bitmask of events to clear. See \ref gpio_irq_level for details.
  ## ```

proc gpioAddRawIrqHandlerWithOrderPriorityMasked*(gpioMask: cuint; handler: IrqHandler; order_priority: uint8) {.importc: "gpio_add_raw_irq_handler_with_order_priority_masked".}
  ## ```
  ##   ! \brief Adds a raw GPIO IRQ handler for the specified GPIOs on the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
  ##    it is possible to add explicit GPIO IRQ handlers which are called independent of the default callback. The order
  ##    relative to the default callback can be controlled via the order_priority parameter (the default callback has the priority
  ##    \ref GPIO_IRQ_CALLBACK_ORDER_PRIORITY which defaults to the lowest priority with the intention of it running last).
  ##   
  ##    This method adds such an explicit GPIO IRQ handler, and disables the "default" callback for the specified GPIOs.
  ##   
  ##    \note Multiple raw handlers should not be added for the same GPIOs, and this method will assert if you attempt to.
  ##   
  ##    A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
  ##   
  ##    \code{.c}
  ##    void my_irq_handler(void) {
  ##        if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
  ##           gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
  ##           handle the IRQ
  ##        }
  ##        if (gpio_get_irq_event_mask(my_gpio_num2) & my_gpio_event_mask2) {
  ##           gpio_acknowledge_irq(my_gpio_num2, my_gpio_event_mask2);
  ##           handle the IRQ
  ##        }
  ##    }
  ##    \endcode
  ##   
  ##    @param gpio_mask a bit mask of the GPIO numbers that will no longer be passed to the default callback for this core
  ##    @param handler the handler to add to the list of GPIO IRQ handlers for this core
  ##    @param order_priority the priority order to determine the relative position of the handler in the list of GPIO IRQ handlers for this core.
  ## ```

proc gpioAddRawIrqHandlerWithOrderPriority*(gpio: Gpio; handler: IrqHandler; orderPriority: uint8) {.importc: "gpio_add_raw_irq_handler_with_order_priority".}
  ## ```
  ##   ! \brief Adds a raw GPIO IRQ handler for a specific GPIO on the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
  ##    it is possible to add explicit GPIO IRQ handlers which are called independent of the default callback. The order
  ##    relative to the default callback can be controlled via the order_priority parameter(the default callback has the priority
  ##    \ref GPIO_IRQ_CALLBACK_ORDER_PRIORITY which defaults to the lowest priority with the intention of it running last).
  ##   
  ##    This method adds such a callback, and disables the "default" callback for the specified GPIO.
  ##   
  ##    \note Multiple raw handlers should not be added for the same GPIO, and this method will assert if you attempt to.
  ##   
  ##    A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
  ##   
  ##    \code{.c}
  ##    void my_irq_handler(void) {
  ##        if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
  ##           gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
  ##           handle the IRQ
  ##        }
  ##    }
  ##    \endcode
  ##   
  ##    @param gpio the GPIO number that will no longer be passed to the default callback for this core
  ##    @param handler the handler to add to the list of GPIO IRQ handlers for this core
  ##    @param order_priority the priority order to determine the relative position of the handler in the list of GPIO IRQ handlers for this core.
  ## ```

proc gpioAddRawIrqHandlerMasked*(gpioMask: cuint; handler: IrqHandler) {.importc: "gpio_add_raw_irq_handler_masked".}
  ## ```
  ##   ! \brief Adds a raw GPIO IRQ handler for the specified GPIOs on the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
  ##    it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
  ##   
  ##    This method adds such a callback, and disables the "default" callback for the specified GPIOs.
  ##   
  ##    \note Multiple raw handlers should not be added for the same GPIOs, and this method will assert if you attempt to.
  ##   
  ##    A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
  ##   
  ##    \code{.c}
  ##    void my_irq_handler(void) {
  ##        if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
  ##           gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
  ##           handle the IRQ
  ##        }
  ##        if (gpio_get_irq_event_mask(my_gpio_num2) & my_gpio_event_mask2) {
  ##           gpio_acknowledge_irq(my_gpio_num2, my_gpio_event_mask2);
  ##           handle the IRQ
  ##        }
  ##    }
  ##    \endcode
  ##   
  ##    @param gpio_mask a bit mask of the GPIO numbers that will no longer be passed to the default callback for this core
  ##    @param handler the handler to add to the list of GPIO IRQ handlers for this core
  ## ```

proc gpioAddRawIrqHandler*(gpio: Gpio; handler: IrqHandler) {.importc: "gpio_add_raw_irq_handler".}
  ## ```
  ##   ! \brief Adds a raw GPIO IRQ handler for a specific GPIO on the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
  ##    it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
  ##   
  ##    This method adds such a callback, and disables the "default" callback for the specified GPIO.
  ##   
  ##    \note Multiple raw handlers should not be added for the same GPIO, and this method will assert if you attempt to.
  ##   
  ##    A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
  ##   
  ##    \code{.c}
  ##    void my_irq_handler(void) {
  ##        if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
  ##           gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
  ##           handle the IRQ
  ##        }
  ##    }
  ##    \endcode
  ##   
  ##    @param gpio the GPIO number that will no longer be passed to the default callback for this core
  ##    @param handler the handler to add to the list of GPIO IRQ handlers for this core
  ## ```

proc gpioRemoveRawIrqHandlerMasked*(gpioMask: cuint; handler: IrqHandler) {.importc: "gpio_remove_raw_irq_handler_masked".}
  ## ```
  ##   ! \brief Removes a raw GPIO IRQ handler for the specified GPIOs on the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
  ##    it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
  ##   
  ##    This method removes such a callback, and enables the "default" callback for the specified GPIOs.
  ##   
  ##    @param gpio_mask a bit mask of the GPIO numbers that will now be passed to the default callback for this core
  ##    @param handler the handler to remove from the list of GPIO IRQ handlers for this core
  ## ```

proc gpioRemoveRawIrqHandler*(gpio: Gpio; handler: IrqHandler) {.importc: "gpio_remove_raw_irq_handler".}
  ## ```
  ##   ! \brief Removes a raw GPIO IRQ handler for the specified GPIO on the current core
  ##     \ingroup hardware_gpio
  ##   
  ##    In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
  ##    it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
  ##   
  ##    This method removes such a callback, and enables the "default" callback for the specified GPIO.
  ##   
  ##    @param gpio the GPIO number that will now be passed to the default callback for this core
  ##    @param handler the handler to remove from the list of GPIO IRQ handlers for this core
  ## ```

proc gpioInit*(gpio: Gpio) {.importc: "gpio_init".}
  ## Initialise a Gpio for (enabled I/O and set func to Gpio_FUNC_SIO) 
  ## Clear the output enable (i.e. set to input) Clear any output value.
  ##
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**    Gpio number

proc gpioDeinit*(gpio: Gpio) {.importc: "gpio_deinit".}
  ## ```
  ##   ! \brief Resets a GPIO back to the NULL function, i.e. disables it.
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ## ```

proc gpioInitMask*(gpioMask: cuint) {.importc: "gpio_init_mask".}
  ## Initialise multiple Gpios (enabled I/O and set func to Gpio_FUNC_SIO).
  ## Clear the output enable (i.e. set to input) Clear any output value.
  ##
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **gpioMask**      Mask with 1 bit per Gpio number to initialize 

proc gpioGet*(gpio: Gpio): Value #[bool]# {.importc: "gpio_get".}
  ## Get state of a single specified Gpio. 
  ## 
  ## **Returns:** Current state of the Gpio. Low (0.Value) or High (1.Value)
  
proc gpioGetAll*(): uint32 {.importc: "gpio_get_all".}
  ## ```
  ##   ! \brief Get raw value of all GPIOs
  ##     \ingroup hardware_gpio
  ##   
  ##    \return Bitmask of raw GPIO values, as bits 0-29
  ## ```

proc gpioSetMask*(mask: uint32) {.importc: "gpio_set_mask".}
  ## ```
  ##   ----------------------------------------------------------------------------
  ##      Output
  ##      ----------------------------------------------------------------------------
  ##     ! \brief Drive high every GPIO appearing in mask
  ##     \ingroup hardware_gpio
  ##   
  ##    \param mask Bitmask of GPIO values to set, as bits 0-29
  ## ```

proc gpioClrMask*(mask: uint32) {.importc: "gpio_clr_mask".}
  ## ```
  ##   ! \brief Drive low every GPIO appearing in mask
  ##     \ingroup hardware_gpio
  ##   
  ##    \param mask Bitmask of GPIO values to clear, as bits 0-29
  ## ```

proc gpioXorMask*(mask: uint32) {.importc: "gpio_xor_mask".}
  ## ```
  ##   ! \brief Toggle every GPIO appearing in mask
  ##     \ingroup hardware_gpio
  ##   
  ##    \param mask Bitmask of GPIO values to toggle, as bits 0-29
  ## ```

proc gpioPutMasked*(mask: uint32; value: uint32) {.importc: "gpio_put_masked".}
  ## ```
  ##   ! \brief Drive GPIO high/low depending on parameters
  ##     \ingroup hardware_gpio
  ##   
  ##    \param mask Bitmask of GPIO values to change, as bits 0-29
  ##    \param value Value to set
  ##   
  ##    For each 1 bit in \p mask, drive that pin to the value given by
  ##    corresponding bit in \p value, leaving other pins unchanged.
  ##    Since this uses the TOGL alias, it is concurrency-safe with e.g. an IRQ
  ##    bashing different pins from the same core.
  ## ```

proc gpioPutAll*(value: uint32) {.importc: "gpio_put_all".}
  ## ```
  ##   ! \brief Drive all pins simultaneously
  ##     \ingroup hardware_gpio
  ##   
  ##    \param value Bitmask of GPIO values to change, as bits 0-29
  ## ```

proc gpioPut*(gpio: Gpio, value: Value #[bool]#) {.importc: "gpio_put".}
  ## Drive a single Gpio high/low. 
  ## 
  ## **Parameters:**
  ## 
  ## =======================================  ====== 
  ## **gpio**                                 Gpio number
  ## **High**, **Low**, **true**, **false**   High or true sets output, otherwise clears Gpio

proc gpioGetOutLevel*(gpio: Gpio): bool {.importc: "gpio_get_out_level".}
  ## ```
  ##   ! \brief Determine whether a GPIO is currently driven high or low
  ##     \ingroup hardware_gpio
  ##   
  ##    This function returns the high/low output level most recently assigned to a
  ##    GPIO via gpio_put() or similar. This is the value that is presented outward
  ##    to the IO muxing,not* the input level back from the pad (which can be
  ##    read using gpio_get()).
  ##   
  ##    To avoid races, this function must not be used for read-modify-write
  ##    sequences when driving GPIOs -- instead functions like gpio_put() should be
  ##    used to atomically update GPIOs. This accessor is intended for debug use
  ##    only.
  ##   
  ##    \param gpio GPIO number
  ##    \return true if the GPIO output level is high, false if low.
  ## ```

proc gpioSetDirOutMasked*(mask: uint32) {.importc: "gpio_set_dir_out_masked".}
  ## ```
  ##   ----------------------------------------------------------------------------
  ##      Direction
  ##      ----------------------------------------------------------------------------
  ##     ! \brief Set a number of GPIOs to output
  ##     \ingroup hardware_gpio
  ##   
  ##    Switch all GPIOs in "mask" to output
  ##   
  ##    \param mask Bitmask of GPIO to set to output, as bits 0-29
  ## ```

proc gpioSetDirInMasked*(mask: uint32) {.importc: "gpio_set_dir_in_masked".}
  ## ```
  ##   ! \brief Set a number of GPIOs to input
  ##     \ingroup hardware_gpio
  ##   
  ##    \param mask Bitmask of GPIO to set to input, as bits 0-29
  ## ```

proc gpioSetDirMasked*(mask: uint32; value: uint32) {.importc: "gpio_set_dir_masked".}
  ## ```
  ##   ! \brief Set multiple GPIO directions
  ##     \ingroup hardware_gpio
  ##   
  ##    \param mask Bitmask of GPIO to set to input, as bits 0-29
  ##    \param value Values to set
  ##   
  ##    For each 1 bit in "mask", switch that pin to the direction given by
  ##    corresponding bit in "value", leaving other pins unchanged.
  ##    E.g. gpio_set_dir_masked(0x3, 0x2); -> set pin 0 to input, pin 1 to output,
  ##    simultaneously.
  ## ```

proc gpioSetDirAllBits*(values: uint32) {.importc: "gpio_set_dir_all_bits".}
  ## ```
  ##   ! \brief Set direction of all pins simultaneously.
  ##     \ingroup hardware_gpio
  ##   
  ##    \param values individual settings for each gpio; for GPIO N, bit N is 1 for out, 0 for in
  ## ```

proc gpioSetDir*(gpio: Gpio, `out`: bool) {.importc: "gpio_set_dir".}
  ## Set a single Gpio direction. 
  ## 
  ## **Parameters:**
  ## 
  ## =====================================  ====== 
  ## **gpio**                               Gpio number
  ## **In**, **Out**, **true**, **false**   true or Output for output; In or false for input

proc gpioIsDirOut*(gpio: Gpio): bool {.importc: "gpio_is_dir_out".}
  ## ```
  ##   ! \brief Check if a specific GPIO direction is OUT
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \return true if the direction for the pin is OUT
  ## ```

proc gpioGetDir*(gpio: Gpio): uint {.importc: "gpio_get_dir".}
  ## ```
  ##   ! \brief Get a specific GPIO direction
  ##     \ingroup hardware_gpio
  ##   
  ##    \param gpio GPIO number
  ##    \return 1 for out, 0 for in
  ## ```

{.pop.}

#[

proc put*(gpio: Gpio, value: bool) =
  gpio.gpioPut(
    if value:
      High
    else:
      Low)

template setupGpio*(name: untyped, pin: Gpio, dir: bool) =
  # Makes a `const 'name' = pin; init(name); name.setDir(dir)
  const name = pin
  init(name)
  gpioSetDir(name, dir)
  
proc init*( _ : typedesc[Gpio], pin: range[0 .. 35], dir = Out): Gpio =
  ## perform the typical assignment, init(), and setDir() steps all in one proc. 
  ## 
  ## **parameters**
  ## **pin** : *int* (between 0 and 35) - the pin number corresponding the the Gpio pin
  ## **dir** : *bool* [optional, defaults to Out] - *Out* or *In*
  
  result = pin.Gpio
  result.gpioInit()
  result.gpioSetDir(dir)

]#
