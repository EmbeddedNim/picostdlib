{.push header: "pico/bit_ops.h".}

proc rev*(bits: uint32): uint32 {.importc: "__rev".}
  ## ```
  ##   ! \brief Reverse the bits in a 32 bit word
  ##     \ingroup pico_bit_ops
  ##   
  ##    \param bits 32 bit input
  ##    \return the 32 input bits reversed
  ## ```

proc revll*(bits: uint64): uint64 {.importc: "__revll".}
  ## ```
  ##   ! \brief Reverse the bits in a 64 bit double word
  ##     \ingroup pico_bit_ops
  ##   
  ##    \param bits 64 bit input
  ##    \return the 64 input bits reversed
  ## ```

{.pop.}
