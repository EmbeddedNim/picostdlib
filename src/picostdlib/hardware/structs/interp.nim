import ../base

{.push header: "hardware/structs/interp.h".}

type
  InterpHw* {.bycopy, importc: "interp_hw_t".} = object
    accum* {.importc.}: array[2, IoRw32]
    base* {.importc.}: array[3, IoRw32]
    pop* {.importc.}: array[3, IoRo32]
    peek* {.importc.}: array[3, IoRo32]
    ctrl* {.importc.}: array[2, IoRw32]
    addRaw* {.importc: "add_raw"}: array[2, IoRw32]
    base01* {.importc.}: IoWo32

{.pop.}
