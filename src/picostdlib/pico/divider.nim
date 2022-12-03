import ../hardware/divider
export divider

{.push header: "pico/divider.h".}

proc div_s32s32*(a: int32; b: int32): int32 {.importc.}
  ## ```
  ##   \defgroup pico_divider pico_divider
  ##    Optimized 32 and 64 bit division functions accelerated by the RP2040 hardware divider.
  ##    Additionally provides integration with the C / and % operators
  ##    
  ##      \file pico/divider.h
  ##   \brief High level APIs including combined quotient and remainder functions for 32 and 64 bit accelerated by the hardware divider
  ##   \ingroup pico_divider
  ##  
  ##   These functions all call __aeabi_idiv0 or __aebi_ldiv0 on division by zero
  ##   passing the largest applicably signed value
  ##  
  ##   Functions with unsafe in their name do not save/restore divider state, so are unsafe to call from interrupts. Unsafe functions are slightly faster.
  ##   
  ##     
  ##    \brief Integer divide of two signed 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient
  ## ```
proc divmod_s32s32_rem*(a: int32; b: int32; rem: ptr int32): int32 {.importc.}
  ## ```
  ##   \brief Integer divide of two signed 32-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ## ```
proc divmod_s32s32*(a: int32; b: int32): HwDivmodResult {.importc.}
  ## ```
  ##   \brief Integer divide of two signed 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in low word/r0, remainder in high word/r1
  ## ```
proc div_u32u32*(a: uint32; b: uint32): uint32 {.importc.}
  ## ```
  ##   \brief Integer divide of two unsigned 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return Quotient
  ## ```
proc divmod_u32u32_rem*(a: uint32; b: uint32; rem: ptr uint32): uint32 {.
    importc.}
  ## ```
  ##   \brief Integer divide of two unsigned 32-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ## ```
proc divmod_u32u32*(a: uint32; b: uint32): HwDivmodResult {.importc.}
  ## ```
  ##   \brief Integer divide of two unsigned 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in low word/r0, remainder in high word/r1
  ## ```
proc div_s64s64*(a: int64; b: int64): int64 {.importc.}
  ## ```
  ##   \brief Integer divide of two signed 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return Quotient
  ## ```
proc divmod_s64s64_rem*(a: int64; b: int64; rem: ptr int64): int64 {.importc.}
  ## ```
  ##   \brief Integer divide of two signed 64-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ## ```
proc divmod_s64s64*(a: int64; b: int64): int64 {.importc.}
  ## ```
  ##   \brief Integer divide of two signed 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in result (r0,r1), remainder in regs (r2, r3)
  ## ```
proc div_u64u64*(a: uint64; b: uint64): uint64 {.importc.}
  ## ```
  ##   \brief Integer divide of two unsigned 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return Quotient
  ## ```
proc divmod_u64u64_rem*(a: uint64; b: uint64; rem: ptr uint64): uint64 {.
    importc.}
  ## ```
  ##   \brief Integer divide of two unsigned 64-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ## ```
proc divmod_u64u64*(a: uint64; b: uint64): uint64 {.importc.}
  ## ```
  ##   \brief Integer divide of two signed 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in result (r0,r1), remainder in regs (r2, r3)
  ## ```
proc div_s32s32_unsafe*(a: int32; b: int32): int32 {.importc.}
  ## ```
  ##   -----------------------------------------------------------------------
  ##      these "unsafe" functions are slightly faster, but do not save the divider state,
  ##      so are not generally safe to be called from interrupts
  ##      -----------------------------------------------------------------------
  ##     
  ##    \brief Unsafe integer divide of two signed 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_s32s32_rem_unsafe*(a: int32; b: int32; rem: ptr int32): int32 {.
    importc.}
  ## ```
  ##   \brief Unsafe integer divide of two signed 32-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_s32s32_unsafe*(a: int32; b: int32): int64 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two unsigned 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in low word/r0, remainder in high word/r1
  ##   
  ##    Do not use in interrupts
  ## ```
proc div_u32u32_unsafe*(a: uint32; b: uint32): uint32 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two unsigned 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return Quotient
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_u32u32_rem_unsafe*(a: uint32; b: uint32; rem: ptr uint32): uint32 {.
    importc.}
  ## ```
  ##   \brief Unsafe integer divide of two unsigned 32-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_u32u32_unsafe*(a: uint32; b: uint32): uint64 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two unsigned 32-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in low word/r0, remainder in high word/r1
  ##   
  ##    Do not use in interrupts
  ## ```
proc div_s64s64_unsafe*(a: int64; b: int64): int64 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two signed 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return Quotient
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_s64s64_rem_unsafe*(a: int64; b: int64; rem: ptr int64): int64 {.
    importc.}
  ## ```
  ##   \brief Unsafe integer divide of two signed 64-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_s64s64_unsafe*(a: int64; b: int64): int64 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two signed 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in result (r0,r1), remainder in regs (r2, r3)
  ##   
  ##    Do not use in interrupts
  ## ```
proc div_u64u64_unsafe*(a: uint64; b: uint64): uint64 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two unsigned 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return Quotient
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_u64u64_rem_unsafe*(a: uint64; b: uint64; rem: ptr uint64): uint64 {.
    importc.}
  ## ```
  ##   \brief Unsafe integer divide of two unsigned 64-bit values, with remainder
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \param [out] rem The remainder of dividend/divisor
  ##    \return Quotient result of dividend/divisor
  ##   
  ##    Do not use in interrupts
  ## ```
proc divmod_u64u64_unsafe*(a: uint64; b: uint64): uint64 {.importc.}
  ## ```
  ##   \brief Unsafe integer divide of two signed 64-bit values
  ##    \ingroup pico_divider
  ##   
  ##    \param a Dividend
  ##    \param b Divisor
  ##    \return quotient in result (r0,r1), remainder in regs (r2, r3)
  ##   
  ##    Do not use in interrupts
  ## ```


{.pop.}