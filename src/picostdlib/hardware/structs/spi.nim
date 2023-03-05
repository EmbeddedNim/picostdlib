{.push header: "hardware/structs/spi.h".}

type
  SpiHw* {.importc: "spi_hw_t".} = object

let
  spi0Hw* {.importc: "spi0_hw".}: ptr SpiHw
  spi1Hw* {.importc: "spi1_hw".}: ptr SpiHw

{.pop.}
