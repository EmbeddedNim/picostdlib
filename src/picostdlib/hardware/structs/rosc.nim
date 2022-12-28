import ../base

{.push header: "hardware/structs/rosc.h".}

type
  RoscHw* {.importc: "rosc_hw_t".} = object
    randombit* {.importc.}: IoRo32

let roscHw* {.importc: "rosc_hw".}: ptr RoscHw

{.pop.}
