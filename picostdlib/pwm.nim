import gpio
export gpio
{.push header: "hardware/pwm.h".}
type
  ClockDivideMode* {.pure, importc: "enum pwm_clkdiv_mode".} = enum
    freeRunning, high, rising, falling
  PwmConfig* {.importC: "pwm_config".} = object
    csr, divide, top: uint32
  PwmChannel* {.pure, importC: "enum pwm_chan", size: sizeof(cuint).} = enum
    A, B

proc toSliceNum*(gpio: Gpio): cuint {.importC: "pwm_gpio_to_slice_num".}
proc setWrap*(sliceNum: cuint, wrap: uint16) {.importC: "pwm_set_wrap".}
proc setChanLevel*(sliceNum: cuint, chan: PwmChannel, level: uint16){.
    importC: "pwm_set_chan_level".}
proc setBothLevels*(sliceNum: cuint, levelA, levelB: uint16){.importC: "pwm_set_both_levels".}
proc setLevel*(gpio: Gpio, level: uint16){.importC: "pwm_set_gpio_level".}
proc getCounter*(sliceNum: cuint): uint16 {.importC: "pwm_get_counter".}
proc setCounter*(sliceNum: cuint, level: uint16) {.importC: "pwm_set_counter".}
proc advanceCount*(sliceNum: cuint){.importC: "pwm_advance_count".}
proc retardCount*(sliceNum: cuint){.importC: "pwm_retard_count".}
proc setClockDivide*(sliceNum: cuint, integer, divide: byte){.importC: "pwm_set_clkdiv_int_frac".}
proc setClockDivide*(sliceNum: cuint, divider: float){.importC: "pwm_set_clkdiv".}
proc setClockDivide*(pwmConfig: PwmConfig, divider: float){.importC: "pwm_config_set_clkdiv".}
proc setClockDivide*(pwmConfig: PwmConfig, divider: cuint){.importC: "pwm_config_set_clkdiv_int".}
proc setWrap*(pwmConfig: PwmConfig, wrap: uint16){.importc: "pwm_config_set_wrap".}
proc init*(sliceNum: cuint, pwmConfig: PwmConfig, start: bool){.importC: "pwm_init".}
proc getDefaultConfig*: PwmConfig {.importc: "pwm_get_default_config".}
proc setOutputPolarity*(sliceNum: cuint, a, b: bool){.importC: "pwm_set_output_polarity".}
proc setClockDivideMode*(sliceNum: cuint, mode: ClockDivideMode){.importc: "pwm_set_clkdiv_mode".}
proc setClockDivideMode*(pwmConfig: PwmConfig, mode: ClockDivideMode){.
    importc: "pwm_config_set_clkdiv_mode".}
proc setPhaseCorrect*(sliceNum: cuint, phaseCorrect: bool){.importC: "pwm_set_phase_correct".}
proc setPhaseCorrect*(pwmcfg: PwmConfig, phaseCorrect: bool){.
    importC: "pwm_confiig_set_phase_correct".}
proc setEnabled*(sliceNum: cuint, enabled: bool){.importC: "pwm_set_enabled".}
proc setEnabled*(sliceNum: cuint, mask: set[0..7]){.importc: "pwm_set_mask_enabled".}
proc setIrqEnabled*(sliceNum: cuint, enabled: bool){.importc: "pwm_set_irq_enabled".}
proc setIrqEnabled*(sliceMask: set[0..31], enabled: bool){.importC: "pwm_set_irq_mask_enabled".}
proc clear*(sliceNim: cuint){.importC: "pwm_clear_irq".}
proc getStatus*: uint32 {.importc: "pwm_get_irq_status_mask".}
proc forceIrq*(sliceNum: cuint){.importc: "pwm_force_irq".}
{.pop.}
