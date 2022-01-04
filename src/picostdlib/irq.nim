const
  TimerIrq0* = 0.cuint
  TimerIrq1* = 1.cuint
  TimerIrq2* = 2.cuint
  TimerIrq3* = 3.cuint
  PwmIrqWrap* = 4.cuint
  # more required for full compatibility

{.push header: "hardware/irq.h".}

type
  IrqHandler* {.importC: "irq_handler_t".} = proc(){.cDecl.}

proc setExclusiveHandler*(num: cuint, handler: IrqHandler){.importC: "irq_set_exclusive_handler".}
proc setEnabled*(num: cuint, enabled: bool) {.importc: "irq_set_enabled".}

{.pop.}
