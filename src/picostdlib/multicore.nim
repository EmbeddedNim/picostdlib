#version: 0.1.2

{.push header: "pico/multicore.h".} 
type
  ThreadFunc* = proc() {.cDecl.}
proc multicoreLaunchCore1*(p: ThreadFunc) {.importC: "multicore_launch_core1".}

proc multicoreResetCore1*() {.importC: "multicore_reset_core1".}
proc multicoreFifoRvalid*(): bool {.importC: "multicore_fifo_rvalid".}
proc multicoreFifoWready*(): bool {.importC: "multicore_fifo_wready".}
proc multicoreFifoPushBlocking*(data: uint32) {.importC: "multicore_fifo_push_blocking".}
proc multicoreFifoPopBlocking*(): uint32 {.importC: "multicore_fifo_pop_blocking".}
proc multicoreFifoDrain*() {.importC: "multicore_fifo_drain".}
proc multicoreFifoClearIrq*() {.importC: "multicore_fifo_clear_irq".}
proc multicoreFifoGetStatus*(): uint32 {.importC: "multicore_fifo_get_status".}
{.pop.}
