import ../base
export base

{.push header: "hardware/structs/spi.h".}

type
  SpiHw* {.importc: "spi_hw_t".} = object
    dr*: IoRw32
    sr*: IoRo32
    icr*: IoRw32

let
  spi0Hw* {.importc: "spi0_hw".}: ptr SpiHw
  spi1Hw* {.importc: "spi1_hw".}: ptr SpiHw

{.pop.}
