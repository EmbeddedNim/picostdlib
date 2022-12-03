import ../base

{.push header: "hardware/structs/spi.h".}

type
  SpiHw* {.importc: "struct spi_hw_t".} = object
    cr0* {.importc.}: IoRw32
    cr1* {.importc.}: IoRw32
    dr* {.importc.}: IoRw32
    sr* {.importc.}: IoRo32
    cpsr* {.importc.}: IoRw32
    imsc* {.importc.}: IoRw32
    ris* {.importc.}: IoRo32
    mis* {.importc.}: IoRo32
    icr* {.importc.}: IoRw32
    dmacr* {.importc.}: IoRw32

{.pop.}
