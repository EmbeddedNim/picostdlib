{.push header: "pico/platform.h".}

proc breakpoint*() {.importc: "__breakpoint".}
  ## ```
  ##   ! \brief Execute a breakpoint instruction
  ##     \ingroup pico_platform
  ## ```
proc compiler_memory_barrier*() {.importc: "__compiler_memory_barrier".}
  ## ```
  ##   ! \brief Ensure that the compiler does not move memory access across this method call
  ##     \ingroup pico_platform
  ##   
  ##     For example in the following code:
  ##   
  ##        some_memory_location = var_a;
  ##         __compiler_memory_barrier();
  ##         uint32_t var_b =some_other_memory_location
  ##   
  ##    The compiler will not move the load from some_other_memory_location above the memory barrier (which it otherwise
  ##    might - even above the memory store!)
  ## ```
proc panic_unsupported*() {.importc.}
  ## ```
  ##   ! \brief Panics with the message "Unsupported"
  ##     \ingroup pico_platform
  ##     \see panic
  ## ```
proc panic*(fmt: cstring) {.importc, varargs.}
  ## ```
  ##   ! \brief Displays a panic message and halts execution
  ##     \ingroup pico_platform
  ##   
  ##    An attempt is made to output the message to all registered STDOUT drivers
  ##    after which this method executes a BKPT instruction.
  ##   
  ##    @param fmt format string (printf-like)
  ##    @param ...  printf-like arguments
  ## ```

proc rp2040_chip_version*(): uint8 {.importc.}
  ## ```
  ##   ! \brief Returns the RP2040 chip revision number
  ##     \ingroup pico_platform
  ##    @return the RP2040 chip revision number (1 for B0/B1, 2 for B2)
  ## ```
proc rp2040_rom_version*(): uint8 {.importc.}
  ## ```
  ##   ! \brief Returns the RP2040 rom version number
  ##     \ingroup pico_platform
  ##    @return the RP2040 rom version number (1 for RP2040-B0, 2 for RP2040-B1, 3 for RP2040-B2)
  ## ```
proc tight_loop_contents*() {.importc.}
  ## ```
  ##   ! \brief No-op function for the body of tight loops
  ##     \ingroup pico_platform
  ##   
  ##    No-op function intended to be called by any tight hardware polling loop. Using this ubiquitously
  ##    makes it much easier to find tight loops, but also in the future \#ifdef-ed support for lockup
  ##    debugging might be added
  ## ```
proc mul_instruction*(a: int32; b: int32): int32 {.importc: "__mul_instruction".}
  ## ```
  ##   ! \brief Multiply two integers using an assembly MUL instruction
  ##     \ingroup pico_platform
  ##   
  ##    This multiplies a by b using multiply instruction using the ARM mul instruction regardless of values (the compiler
  ##    might otherwise choose to perform shifts/adds), i.e. this is a 1 cycle operation.
  ##   
  ##    \param a the first operand
  ##    \param b the second operand
  ##    \return a b
  ## ```
proc get_current_exception*(): uint {.importc: "__get_current_exception".}
  ## ```
  ##   ! \brief Get the current exception level on this core
  ##     \ingroup pico_platform
  ##   
  ##    \return the exception number if the CPU is handling an exception, or 0 otherwise
  ## ```
proc busy_wait_at_least_cycles*(minimum_cycles: uint32) {.importc.}
  ## ```
  ##   ! \brief Helper method to busy-wait for at least the given number of cycles
  ##     \ingroup pico_platform
  ##   
  ##    This method is useful for introducing very short delays.
  ##   
  ##    This method busy-waits in a tight loop for the given number of system clock cycles. The total wait time is only accurate to within 2 cycles,
  ##    and this method uses a loop counter rather than a hardware timer, so the method will always take longer than expected if an
  ##    interrupt is handled on the calling core during the busy-wait; you can of course disable interrupts to prevent this.
  ##   
  ##    You can use \ref clock_get_hz(clk_sys) to determine the number of clock cycles per second if you want to convert an actual
  ##    time duration to a number of cycles.
  ##   
  ##    \param minimum_cycles the minimum number of system clock cycles to delay for
  ## ```
proc get_core_num*(): uint {.importc.}
  ## ```
  ##   ! \brief Get the current core number
  ##     \ingroup pico_platform
  ##   
  ##    \return The core number the call was made from
  ## ```

{.pop.}
