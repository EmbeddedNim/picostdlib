import ./regs/resets
export resets

{.push header: "hardware/resets.h".}

proc resetBlock*(bits: uint32) {.importc: "reset_block".}
  ## ```
  ##     ! \brief Reset the specified HW blocks
  ##     \ingroup hardware_resets
  ##   
  ##    \param bits Bit pattern indicating blocks to reset. See \ref reset_bitmask
  ## ```

proc unresetBlock*(bits: uint32) {.importc: "unreset_block".}
  ## ```
  ##   ! \brief bring specified HW blocks out of reset
  ##     \ingroup hardware_resets
  ##   
  ##    \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask
  ## ```

proc unresetBlockWait*(bits: uint32) {.importc: "unreset_block_wait".}
  ## ```
  ##   ! \brief Bring specified HW blocks out of reset and wait for completion
  ##     \ingroup hardware_resets
  ##   
  ##    \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask
  ## ```

{.pop.}
