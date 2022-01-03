import gpio
export gpio
{.push header: "hardware/pwm.h".}
type
  ClockDivideMode* {.pure, importc: "enum pwm_clkdiv_mode".} = enum
    ## PWM Divider mode settings. 
    ## 
    ## **Modes:**
    ## 
    ## ================  ====== 
    ## **freeRunning**    Free-running counting at rate dictated by fractional divider. 
    ## **high**           Fractional divider is gated by the PWM B pin. 
    ## **rising**         Fractional divider advances with each rising edge of the PWM B pin. 
    ## **falling**        Fractional divider advances with each falling edge of the PWM B pin. 
    ## ================  ====== 
    ##
    ## 
    freeRunning, high, rising, falling
  PwmConfig* {.importC: "pwm_config".} = object
    ## Configuration object for PWM  tasks
    csr, divide, top: uint32

  PwmChannel* {.pure, importC: "enum pwm_chan", size: sizeof(cuint).} = enum
    ## Alias for channel parameter in the setChanLevel() procedure
    A, B


proc toSliceNum*(gpio: Gpio): cuint {.importC: "pwm_gpio_to_slice_num".}
  ## Determine the PWM slice that is attached to the specified GPIO. 
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **gpio**     Gpio number
  ## =========  ====== 
  ##
  ## **Returns** The PWM slice number that controls the specified GPIO. 

proc setWrap*(sliceNum: cuint, wrap: uint16) {.importC: "pwm_set_wrap".}
  ## Set the highest value the counter will reach before returning to 0. Also known as TOP.
  ## 
  ## The counter wrap value is double-buffered in hardware. This means that, 
  ## when the PWM is running, a write to the counter wrap value does not take 
  ## effect until after the next time the PWM slice wraps (or, in phase-correct 
  ## mode, the next time the slice reaches 0). If the PWM is not running, the 
  ## write is latched in immediately.
  ## 
  ## **Parameters:**
  ## 
  ## ==============  ====== 
  ## **sliceNum**     PWM slice number
  ## **wrap**         Value to set wrap to 
  ## ==============  ====== 
 
proc setChanLevel*(sliceNum: cuint, chan: PwmChannel, level: uint16){.
    importC: "pwm_set_chan_level".}
  ## Set the value of the PWM counter compare value, for either channel A or channel B 
  ## 
  ## The counter compare register is double-buffered in hardware. This means 
  ## that, when the PWM is running, a write to the counter compare values does 
  ## not take effect until the next time the PWM slice wraps (or, in 
  ## phase-correct mode, the next time the slice reaches 0). If the PWM is not 
  ## running, the write is latched in immediately.
  ## 
  ## **Parameters:**
  ## 
  ## ==============  ====== 
  ## **sliceNum**     PWM slice number
  ## **chan**         Which channel to update. 0 for A, 1 for B. 
  ## **level**        new level for the selected output 
  ## ==============  ====== 

proc setBothLevels*(sliceNum: cuint, levelA, levelB: uint16){.importC: "pwm_set_both_levels".}
  ## Set the value of the PWM counter compare values, A and B
  ## 
  ## The counter compare register is double-buffered in hardware. This means 
  ## that, when the PWM is running, a write to the counter compare values does 
  ## not take effect until the next time the PWM slice wraps (or, in 
  ## phase-correct mode, the next time the slice reaches 0). If the PWM is not 
  ## running, the write is latched in immediately.
  ## 
  ## **Parameters:**
  ## 
  ## ==============  ====== 
  ## **sliceNum**     PWM slice number
  ## **levelA**       Value to set compare A to. When the counter reaches this value the A output is deasserted 
  ## **levelB**       Value to set compare B to. When the counter reaches this value the B output is deasserted 
  ## ==============  ====== 

proc setLevel*(gpio: Gpio, level: uint16){.importC: "pwm_set_gpio_level".}
  ## Helper procedure to set the PWM level for the slice and channel associated with a GPIO. 
  ## 
  ## Look up the correct slice (0 to 7) and channel (A or B) for a given GPIO, 
  ## and update the corresponding counter-compare field.
  ## 
  ## This PWM slice should already have been configured and set running. Also 
  ## be careful of multiple GPIOs mapping to the same slice and channel 
  ## (if GPIOs have a difference of 16).
  ## 
  ## The counter compare register is double-buffered in hardware. This means 
  ## that, when the PWM is running, a write to the counter compare values does 
  ## not take effect until the next time the PWM slice wraps (or, in 
  ## phase-correct mode, the next time the slice reaches 0). If the PWM is not 
  ## running, the write is latched in immediately.
  ## 
  ## **Parameters:**
  ## 
  ## ==========  ====== 
  ## **gpio**     Gpio to set level of
  ## **level**    PWM level for this GPIO 
  ## ==========  ====== 

proc getCounter*(sliceNum: cuint): uint16 {.importC: "pwm_get_counter".}
  ## Get current value of PWM counter
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## =============  ====== 
  ## 
  ## **Returns:** Current value of PWM counter 

proc setCounter*(sliceNum: cuint, level: uint16) {.importC: "pwm_set_counter".}
  ## Set the value of the PWM counter
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## **level**       Value to set the PWM counter to 
  ## =============  ====== 
  ## 
proc advanceCount*(sliceNum: cuint){.importC: "pwm_advance_count".}
  ## Advance the phase of a running the counter by 1 count.
  ## 
  ## This procedure will return once the increment is complete.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## =============  ====== 
  ## 

proc retardCount*(sliceNum: cuint){.importC: "pwm_retard_count".}
  ## Retard the phase of a running counter by 1 count
  ## This procedure will return once the retardation is complete.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## =============  ====== 
  ## 

proc setClockDivide*(sliceNum: cuint, integer, divide: byte){.importC: "pwm_set_clkdiv_int_frac".}
  ## Set the clock divider. Counter increment will be on sysclock divided by 
  ## this value, taking in to account the gating.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## **integer**     8 bit integer part of the clock divider 
  ## **divide**      4 bit fractional part of the clock divider 
  ## =============  ====== 
  ## 
proc setClockDivide*(sliceNum: cuint, divider: float){.importC: "pwm_set_clkdiv".}
  ## Set the clock divider. Counter increment will be on sysclock divided by 
  ## this value, taking in to account the gating.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## **divider**     Floating point clock divider, 1.float <= value < 256.float 
  ## =============  ====== 
  ## 
proc setClockDivide*(pwmConfig: ptr PwmConfig, divider: float){.importC: "pwm_config_set_clkdiv".}
  ## Set clock divider in a PWM configuration. 
  ## 
  ## If the divide mode is free-running, the PWM counter runs at clk_sys / div. 
  ## Otherwise, the divider reduces the rate of events seen on the B pin input 
  ## (level or edge) before passing them on to the PWM counter. 
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **pwmConfig**   PWM configuration object to modify 
  ## **divider**     Floating point clock divider, 1.float <= value < 256.float 
  ## =============  ====== 
  ## 
proc setClockDivide*(pwmConfig: ptr PwmConfig, divider: cuint){.importC: "pwm_config_set_clkdiv_int".}
  ## Set PWM clock divider in a PWM configuration. 
  ## 
  ## If the divide mode is free-running, the PWM counter runs at clk_sys / div. 
  ## Otherwise, the divider reduces the rate of events seen on the B pin input 
  ## (level or edge) before passing them on to the PWM counter. 
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **pwmConfig**   PWM configuration object to modify 
  ## **divider**     Integer value to reduce counting rate by. Must be greater than or equal to 1.
  ## =============  ====== 
  ## 
proc setWrap*(pwmConfig: ptr PwmConfig, wrap: uint16){.importc: "pwm_config_set_wrap".}
  ## Set PWM counter wrap value in a PWM configuration. 
  ## 
  ## Set the highest value the counter will reach before returning to 0. Also 
  ## known as TOP.
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **pwmConfig**   PWM configuration object to modify 
  ## **wrap**        Value to set wrap to
  ## =============  ====== 
  ## 

proc init*(sliceNum: cuint, pwmConfig: ptr PwmConfig, start: bool){.importC: "pwm_init".}
  ## Initialise a PWM with settings from a configuration object. 
  ## 
  ## Use the getDefaultConfig() procedure to initialise a config objecture, 
  ## make changes as needed using the pwm_config_* procedures, then call this 
  ## procedure to set up the PWM.
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number
  ## **pwmConfig**   PWM configuration object to modify 
  ## **start**       If true the PWM will be started running once configured. If false you will need to start manually using pwm_set_enabled() or pwm_set_mask_enabled() 
  ## =============  ====== 

proc getDefaultConfig*(): PwmConfig {.importc: "pwm_get_default_config".}
  ## Get a set of default values for PWM configuration. 
  ## 
  ## PWM config is free running at system clock speed, no phase correction, 
  ## wrapping at 0xffff, with standard polarities for channels A and B.
  ## 
  ## **Returns:** Set of default values. 

proc setOutputPolarity*(sliceNum: cuint, a, b: bool){.importC: "pwm_set_output_polarity".}
  ## Set PWM output polarity. 
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number
  ## **a**           true to invert output A 
  ## **b**           true to invert output B 
  ## =============  ====== 

proc setClockDivideMode*(sliceNum: cuint, mode: ClockDivideMode){.importc: "pwm_set_clkdiv_mode".}
  ## Set PWM divider mode. 
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number
  ## **mode**        Required divider mode 
  ## =============  ====== 

proc setClockDivideMode*(pwmConfig: ptr PwmConfig, mode: ClockDivideMode){.
    importc: "pwm_config_set_clkdiv_mode".}
  ## Set PWM counting mode in a PWM configuration. 
  ## 
  ## Configure which event gates the operation of the fractional divider. The 
  ## default is always-on (free-running PWM). Can also be configured to count on 
  ## high level, rising edge or falling edge of the B pin input. 
  ## 
  ## **Parameters**
  ## 
  ## =============  ====== 
  ## **pwmConfig**   PWM configuration object to modify 
  ## **mode**        Required divider mode 
  ## =============  ====== 

proc setPhaseCorrect*(sliceNum: cuint, phaseCorrect: bool){.importC: "pwm_set_phase_correct".}
  ## Set PWM phase correct on/off. 
  ## 
  ## Setting phase control to true means that instead of wrapping back to zero 
  ## when the wrap point is reached, the PWM starts counting back down. The 
  ## output frequency is halved when phase-correct mode is enabled. 

proc setPhaseCorrect*(pwmcfg: ptr PwmConfig, phaseCorrect: bool){.
    importC: "pwm_config_set_phase_correct".}
  ## Set phase correction in a PWM configuration. 
  ## 
  ## Setting phase control to true means that instead of wrapping back to zero 
  ## when the wrap point is reached, the PWM starts counting back down. The 
  ## output frequency is halved when phase-correct mode is enabled. 
  
proc setEnabled*(sliceNum: cuint, enabled: bool){.importC: "pwm_set_enabled".}
  ## Enable/Disable PWM. 
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## **enabled**     true to enable the specified PWM, false to disable 
  ## =============  ====== 
  ##
proc setEnabled*(sliceNum: cuint, mask: set[0..7]){.importc: "pwm_set_mask_enabled".}
  ## Enable/Disable multiple PWM slices simultaneously. 
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## **mask**        Bitmap of PWMs to enable/disable. Bits 0 to 7 enable slices 0-7 respectively 
  ## =============  ====== 
  ## 
proc setIrqEnabled*(sliceNum: cuint, enabled: bool){.importc: "pwm_set_irq_enabled".}
  ## Used to enable a single PWM instance interrupt
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## **enabled**     true to enable, false to disable
  ## =============  ====== 
  ## 
proc setIrqEnabled*(sliceMask: set[0..31], enabled: bool){.importC: "pwm_set_irq_mask_enabled".}
  ## Enable multiple PWM instance interrupts at once.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceMask**    Bitmask of all the blocks to enable/disable. Channel 0 = bit 0, channel 1 = bit 1 etc. 
  ## **enabled**     true to enable, false to disable
  ## =============  ====== 
  ## 
proc clear*(sliceNim: cuint){.importC: "pwm_clear_irq".}
  ## Clear single PWM channel interrupt. 
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## =============  ====== 
  ## 
proc getStatus*: uint32 {.importc: "pwm_get_irq_status_mask".}
  ## Get PWM interrupt status, raw.
  ## 
  ## **Returns:** The PWM channel that controls the specified Gpio

proc forceIrq*(sliceNum: cuint){.importc: "pwm_force_irq".}
  ## Force PWM interrupt. 
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **sliceNum**    PWM slice number 
  ## =============  ======  
{.pop.}
