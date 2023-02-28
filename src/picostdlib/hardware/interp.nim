import ./structs/interp
import ./base

{.push header: "hardware/interp.h".}

type
  InterpConfig* {.bycopy, importc: "interp_config".} = object
    ctrl* {.importc.}: uint32

  InterpHwSave* {.bycopy, importc: "interp_hw_save_t".} = object
    accum* {.importc.}: array[2, IoRw32]
    base* {.importc.}: array[3, IoRw32]
    ctrl* {.importc.}: array[2, IoRw32]

proc interp_claim_lane*(interp: ptr InterpHw; lane: uint) {.importc.}
  ## ```
  ##   ! \brief Claim the interpolator lane specified
  ##     \ingroup hardware_interp
  ##   
  ##    Use this function to claim exclusive access to the specified interpolator lane.
  ##   
  ##    This function will panic if the lane is already claimed.
  ##   
  ##    \param interp Interpolator on which to claim a lane. interp0 or interp1
  ##    \param lane The lane number, 0 or 1.
  ## ```

proc interp_claim_lane_mask*(interp: ptr InterpHw; lane_mask: uint) {.importc.}
  ## ```
  ##   ! \brief Claim the interpolator lanes specified in the mask
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator on which to claim lanes. interp0 or interp1
  ##    \param lane_mask Bit pattern of lanes to claim (only bits 0 and 1 are valid)
  ## ```

proc interp_unclaim_lane*(interp: ptr InterpHw; lane: uint) {.importc.}
  ## ```
  ##   ! \brief Release a previously claimed interpolator lane
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator on which to release a lane. interp0 or interp1
  ##    \param lane The lane number, 0 or 1
  ## ```

proc interp_lane_is_claimed*(interp: ptr InterpHw; lane: uint): bool {.importc.}
  ## ```
  ##   ! \brief Determine if an interpolator lane is claimed
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator whose lane to check
  ##    \param lane The lane number, 0 or 1
  ##    \return true if claimed, false otherwise
  ##    \see interp_claim_lane
  ##    \see interp_claim_lane_mask
  ## ```

proc interp_unclaim_lane_mask*(interp: ptr InterpHw; lane_mask: uint) {.importc.}
  ## ```
  ##   ! \brief Release previously claimed interpolator lanes \see interp_claim_lane_mask
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator on which to release lanes. interp0 or interp1
  ##    \param lane_mask Bit pattern of lanes to unclaim (only bits 0 and 1 are valid)
  ## ```

proc interp_config_set_shift*(c: ptr InterpConfig; shift: uint) {.importc.}
  ## ```
  ##   ! \brief Set the interpolator shift value
  ##     \ingroup interp_config
  ##   
  ##    Sets the number of bits the accumulator is shifted before masking, on each iteration.
  ##   
  ##    \param c Pointer to an interpolator config
  ##    \param shift Number of bits
  ## ```

proc interp_config_set_mask*(c: ptr InterpConfig; mask_lsb: uint;
                             mask_msb: uint) {.importc.}
  ## ```
  ##   ! \brief Set the interpolator mask range
  ##     \ingroup interp_config
  ##   
  ##    Sets the range of bits (least to most) that are allowed to pass through the interpolator
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param mask_lsb The least significant bit allowed to pass
  ##    \param mask_msb The most significant bit allowed to pass
  ## ```

proc interp_config_set_cross_input*(c: ptr InterpConfig; cross_input: bool) {.importc.}
  ## ```
  ##   ! \brief Enable cross input
  ##     \ingroup interp_config
  ##   
  ##     Allows feeding of the accumulator content from the other lane back in to this lanes shift+mask hardware.
  ##     This will take effect even if the interp_config_set_add_raw option is set as the cross input mux is before the
  ##     shift+mask bypass
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param cross_input If true, enable the cross input.
  ## ```

proc interp_config_set_cross_result*(c: ptr InterpConfig; cross_result: bool) {.importc.}
  ## ```
  ##   ! \brief Enable cross results
  ##     \ingroup interp_config
  ##   
  ##     Allows feeding of the other lane’s result into this lane’s accumulator on a POP operation.
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param cross_result If true, enables the cross result
  ## ```

proc interp_config_set_signed*(c: ptr InterpConfig; signed: bool) {.importc.}
  ## ```
  ##   ! \brief Set sign extension
  ##     \ingroup interp_config
  ##   
  ##    Enables signed mode, where the shifted and masked accumulator value is sign-extended to 32 bits
  ##    before adding to BASE1, and LANE1 PEEK/POP results appear extended to 32 bits when read by processor.
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param  _signed If true, enables sign extension
  ## ```

proc interp_config_set_add_raw*(c: ptr InterpConfig; add_raw: bool) {.importc.}
  ## ```
  ##   ! \brief Set raw add option
  ##     \ingroup interp_config
  ##   
  ##    When enabled, mask + shift is bypassed for LANE0 result. This does not affect the FULL result.
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param add_raw If true, enable raw add option.
  ## ```

proc interp_config_set_blend*(c: ptr InterpConfig; blend: bool) {.importc.}
  ## ```
  ##   ! \brief Set blend mode
  ##     \ingroup interp_config
  ##   
  ##    If enabled, LANE1 result is a linear interpolation between BASE0 and BASE1, controlled
  ##    by the 8 LSBs of lane 1 shift and mask value (a fractional number between 0 and 255/256ths)
  ##   
  ##    LANE0 result does not have BASE0 added (yields only the 8 LSBs of lane 1 shift+mask value)
  ##   
  ##    FULL result does not have lane 1 shift+mask value added (BASE2 + lane 0 shift+mask)
  ##   
  ##    LANE1 SIGNED flag controls whether the interpolation is signed or unsig
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param blend Set true to enable blend mode.
  ## ```

proc interp_config_set_clamp*(c: ptr InterpConfig; clamp: bool) {.importc.}
  ## ```
  ##   ! \brief Set interpolator clamp mode (Interpolator 1 only)
  ##     \ingroup interp_config
  ##   
  ##    Only present on INTERP1 on each core. If CLAMP mode is enabled:
  ##    - LANE0 result is a shifted and masked ACCUM0, clamped by a lower bound of BASE0 and an upper bound of BASE1.
  ##    - Signedness of these comparisons is determined by LANE0_CTRL_SIGNED
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param clamp Set true to enable clamp mode
  ## ```

proc interp_config_set_force_bits*(c: ptr InterpConfig; bits: uint) {.importc.}
  ## ```
  ##   ! \brief Set interpolator Force bits
  ##     \ingroup interp_config
  ##   
  ##    ORed into bits 29:28 of the lane result presented to the processor on the bus.
  ##   
  ##    No effect on the internal 32-bit datapath. Handy for using a lane to generate sequence
  ##    of pointers into flash or SRAM
  ##   
  ##    \param c Pointer to interpolation config
  ##    \param bits Sets the force bits to that specified. Range 0-3 (two bits)
  ## ```

proc interp_default_config*(): InterpConfig {.importc.}
  ## ```
  ##   ! \brief Get a default configuration
  ##     \ingroup interp_config
  ##   
  ##    \return A default interpolation configuration
  ## ```

proc interp_set_config*(interp: ptr InterpHw; lane: uint; config: ptr InterpConfig) {.importc.}
  ## ```
  ##   ! \brief Send configuration to a lane
  ##     \ingroup interp_config
  ##   
  ##    If an invalid configuration is specified (ie a lane specific item is set on wrong lane),
  ##    depending on setup this function can panic.
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane to set
  ##    \param config Pointer to interpolation config
  ## ```

proc interp_set_force_bits*(interp: ptr InterpHw; lane: uint; bits: uint) {.importc.}
  ## ```
  ##   ! \brief Directly set the force bits on a specified lane
  ##     \ingroup hardware_interp
  ##   
  ##    These bits are ORed into bits 29:28 of the lane result presented to the processor on the bus.
  ##    There is no effect on the internal 32-bit datapath.
  ##   
  ##    Useful for using a lane to generate sequence of pointers into flash or SRAM, saving a subsequent
  ##    OR or add operation.
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane to set
  ##    \param bits The bits to set (bits 0 and 1, value range 0-3)
  ## ```

proc interp_save*(interp: ptr InterpHw; saver: ptr InterpHwSave) {.importc.}
  ## ```
  ##   ! \brief Save the specified interpolator state
  ##     \ingroup hardware_interp
  ##   
  ##    Can be used to save state if you need an interpolator for another purpose, state
  ##    can then be recovered afterwards and continue from that point
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param saver Pointer to the save structure to fill in
  ## ```

proc interp_restore*(interp: ptr InterpHw; saver: ptr InterpHwSave) {.importc.}
  ## ```
  ##   ! \brief Restore an interpolator state
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param saver Pointer to save structure to reapply to the specified interpolator
  ## ```

proc interp_set_base*(interp: ptr InterpHw; lane: uint; val: uint32) {.importc.}
  ## ```
  ##   ! \brief Sets the interpolator base register by lane
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1 or 2
  ##    \param val The value to apply to the register
  ## ```

proc interp_get_base*(interp: ptr InterpHw; lane: uint): uint32 {.importc.}
  ## ```
  ##   ! \brief Gets the content of interpolator base register by lane
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1 or 2
  ##    \return  The current content of the lane base register
  ## ```

proc interp_set_base_both*(interp: ptr InterpHw; val: uint32) {.importc.}
  ## ```
  ##   ! \brief Sets the interpolator base registers simultaneously
  ##     \ingroup hardware_interp
  ##   
  ##     The lower 16 bits go to BASE0, upper bits to BASE1 simultaneously.
  ##     Each half is sign-extended to 32 bits if that lane’s SIGNED flag is set.
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param val The value to apply to the register
  ## ```

proc interp_set_accumulator*(interp: ptr InterpHw; lane: uint; val: uint32) {.importc.}
  ## ```
  ##   ! \brief Sets the interpolator accumulator register by lane
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1
  ##    \param val The value to apply to the register
  ## ```

proc interp_get_accumulator*(interp: ptr InterpHw; lane: uint): uint32 {.importc.}
  ## ```
  ##   ! \brief Gets the content of the interpolator accumulator register by lane
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1
  ##    \return The current content of the register
  ## ```

proc interp_pop_lane_result*(interp: ptr InterpHw; lane: uint): uint32 {.importc.}
  ## ```
  ##   ! \brief Read lane result, and write lane results to both accumulators to update the interpolator
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1
  ##    \return The content of the lane result register
  ## ```

proc interp_peek_lane_result*(interp: ptr InterpHw; lane: uint): uint32 {.importc.}
  ## ```
  ##   ! \brief Read lane result
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1
  ##    \return The content of the lane result register
  ## ```

proc interp_pop_full_result*(interp: ptr InterpHw): uint32 {.importc.}
  ## ```
  ##   ! \brief Read lane result, and write lane results to both accumulators to update the interpolator
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \return The content of the FULL register
  ## ```

proc interp_peek_full_result*(interp: ptr InterpHw): uint32 {.importc.}
  ## ```
  ##   ! \brief Read lane result
  ##     \ingroup hardware_interp
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \return The content of the FULL register
  ## ```

proc interp_add_accumulater*(interp: ptr InterpHw; lane: uint; val: uint32) {.importc.}
  ## ```
  ##   ! \brief Add to accumulator
  ##     \ingroup hardware_interp
  ##   
  ##    Atomically add the specified value to the accumulator on the specified lane
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1
  ##    \param val Value to add
  ##    \return The content of the FULL register
  ## ```

proc interp_get_raw*(interp: ptr InterpHw; lane: uint): uint32 {.importc.}
  ## ```
  ##   ! \brief Get raw lane value
  ##     \ingroup hardware_interp
  ##   
  ##    Returns the raw shift and mask value from the specified lane, BASE0 is NOT added
  ##   
  ##    \param interp Interpolator instance, interp0 or interp1.
  ##    \param lane The lane number, 0 or 1
  ##    \return The raw shift/mask value
  ## ```

{.pop.}
