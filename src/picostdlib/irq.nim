{.push header: "hardware_irq/irq.h".}
proc setExclusiveHandler*(num: cuint, handler: proc()){.importC: "irq_set_exclusive_handler".}


{.pop.}
