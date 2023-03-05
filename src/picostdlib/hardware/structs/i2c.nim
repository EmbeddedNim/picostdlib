{.push header: "hardware/structs/i2c.h".}

type
  I2cHw* {.importc: "i2c_hw_t".} = object

let
  i2c0Hw* {.importc: "i2c0_hw".}: ptr I2cHw
  i2c1Hw* {.importc: "i2c1_hw".}: ptr I2cHw

{.pop.}
