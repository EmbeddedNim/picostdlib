import gpio

{.push header: "hardware/pio.h".}
type
  PioSmConfig* {.importc: "pio_sm_config", bycopy.} = object
    clkdiv {.importc: "clkdiv".}: uint32
    execctrl {.importc: "execctrl".}: uint32
    shiftctrl {.importc: "shiftctrl".}: uint32
    pinctrl {.importc: "pinctrl".}: uint32

  PioInstanceObj {.importc: "pio_hw_t", nodecl.} = object

  PioInstance* = ptr PioInstanceObj

  PioStateMachine* = range[0'u .. 3'u]

  PioProgram* {.importc: "pio_program_t", nodecl.} = object

  PioFifoJoin* = enum
    none = 0,
    tx = 1,
    rx = 2,

let
  pio0* {.importc, nodecl.}: PioInstance 
  pio1* {.importc, nodecl.}: PioInstance 
{.pop.}

# PIO State Machine Config
# Private C bindings

{.push header: "hardware/pio.h".}
proc smConfigSetOutPins(c: ptr PioSmConfig; outBase: uint; outCount: uint)
  {.importc: "sm_config_set_out_pins".}

proc smConfigSetInPins(c: ptr PioSmConfig; inBase: uint)
  {.importc: "sm_config_set_in_pins".}

proc smConfigSetSetPins(c: ptr PioSmConfig; setBase: uint; setCount: uint)
  {.importc: "sm_config_set_set_pins".}

proc smConfigSetSidesetPins(c: ptr PioSmConfig; sidesetBase: uint)
  {.importc: "sm_config_set_sideset_pins".}

proc smConfigSetSideset(c: ptr PioSmConfig; bitCount: uint; optional: bool;
  pindirs: bool) {.importc: "sm_config_set_sideset".}

proc smConfigSetClkdivIntFrac(c: ptr PioSmConfig; divInt: uint16; divFrac: uint8)
  {.importc: "sm_config_set_clkdiv_int_frac".}

proc smConfigSetClkdiv(c: ptr PioSmConfig, divisor: cfloat)
  {.importc: "sm_config_set_clkdiv".}

proc smConfigSetInShift(c: ptr PioSmConfig; shiftRight: bool; autopush: bool;
  pushThreshold: uint) {.importc: "sm_config_set_in_shift".}

proc smConfigSetOutShift(c: ptr PioSmConfig; shiftRight: bool; autopull: bool;
  pullThreshold: uint) {.importc: "sm_config_set_out_shift".}

proc smConfigSetFifoJoin(c: ptr PioSmConfig; join: PioFifoJoin)
  {.importc: "sm_config_set_fifo_join".}
{.pop.}

# PIO State Machine Config
# Exported Nim API

proc setOutPins*(c: var PioSmConfig, pins: Slice[Gpio]) =
  smConfigSetOutPins(c.addr, pins.a.uint, pins.len.uint)

proc setOutPin*(c: var PioSmConfig, pin: Gpio) =
  smConfigSetOutPins(c.addr, pin.uint, 1)

proc setInPins*(c: var PioSmConfig; inBase: Gpio) =
  smConfigSetInPins(c.addr, inBase.uint)

proc setSetPins*(c: var PioSmConfig; pins: Slice[Gpio]) =
  smConfigSetSetPins(c.addr, pins.a.uint, pins.len.uint)

proc setSidesetPins*(c: var PioSmConfig; sidesetBase: Gpio) =
  smConfigSetSidesetPins(c.addr, sidesetBase.uint)

proc setSideset*(c: var PioSmConfig; bitCount: 1..5; optional: bool; pinDirs: bool) =
  smConfigSetSideset(c.addr, bitCount.uint, optional, pinDirs)

proc setClkDiv*(c: var PioSmConfig; divInt: uint16; divFrac: uint8) =
  smConfigSetClkdivIntFrac(c.addr, divInt, divFrac)

proc setClkDiv*(c: var PioSmConfig; divisor: float32) =
  smConfigSetClkdiv(c.addr, divisor)

template setClkDiv*(c: var PioSmConfig, divisor: static[1.0 .. 65536.0]) =
  ## Template to set floating point clock divisor when it is known at
  ## compile-time. All the float calculation is done in a  static context,
  ## so we can avoid pulling in software-float code in the final binary.
  static:
    let
      divInt = divisor.uint16
      divFrac: uint8 = ((divisor - divInt.float32) * 256).toInt.uint8
  smConfigSetClkdivIntFrac(c.addr, divInt, divFrac)

proc setInShift*(c: var PioSmConfig; shiftRight: bool; autopush: bool;
    pushThreshold: uint) =
  smConfigSetInShift(c.addr, shiftRight, autopush, pushThreshold)

proc setOutShift*(c: var PioSmConfig; shiftRight: bool; autopull: bool;
    pullThreshold: uint) =
  smConfigSetOutShift(c.addr, shiftRight, autopull, pullThreshold)

proc setFifoJoin*(c: var PioSmConfig; join: PioFifoJoin)  =
  smConfigSetFifoJoin(c.addr, join)
  
# Main PIO API

{.push header: "hardware/pio.h".}
proc gpioInit*(pio: PioInstance; pin: Gpio)
  {.importc: "pio_gpio_init".}

proc canAddProgram(pio: PioInstance; program: ptr PioProgram): bool
  {.importc: "pio_can_add_program".}

proc canAddProgram(pio: PioInstance; program: ptr PioProgram; offset: uint): bool
  {.importc: "pio_can_add_program_at_offset".}

proc addProgram(pio: PioInstance; program: ptr PioProgram): uint
  {.importc: "pio_add_program".}

proc addProgram(pio: PioInstance; program: ptr PioProgram; offset: uint)
  {.importc: "pio_add_program_at_offset".}

proc removeProgram(pio: PioInstance; program: ptr PioProgram; loadedOffset: uint)
  {.importc: "pio_remove_program".}

proc clearInstructionMemory*(pio: PioInstance) {.importc: "pio_clear_instruction_memory".}
{.pop}

proc canAddProgram*(pio: PioInstance; program: PioProgram): bool =
  var p = program
  canAddProgram(pio, p.addr)

proc canAddProgram*(pio: PioInstance; program: PioProgram; offset: uint): bool =
  var p = program
  canAddProgram(pio, p.addr, offset)

proc addProgram*(pio: PioInstance; program: PioProgram): uint =
  var p = program
  addProgram(pio, p.addr)

proc addProgram*(pio: PioInstance; program: PioProgram; offset: uint) =
  var p = program
  addProgram(pio, p.addr, offset)

proc removeProgram*(pio: PioInstance; program: PioProgram; loadedOffset: uint) =
  var p = program
  removeProgram(pio, p.addr, loadedOffset)

# State Machine API

{.push header: "hardware/pio.h".}
proc setPinsWithMask(pio: PioInstance; sm: PioStateMachine; pinValues: uint32; pinMask: uint32)
  {.importc: "pio_sm_set_pins_with_mask".}

proc setPindirsWithMask(pio: PioInstance; sm: PioStateMachine; pinDirs: uint32; pinMask: uint32)
  {.importc: "pio_sm_set_pindirs_with_mask".}

proc setConsecutivePindirs(pio: PioInstance; sm: PioStateMachine; pinBase: uint; pinCount: uint;
  isOut: bool) {.importc: "pio_sm_set_consecutive_pindirs"}

proc claim*(pio: PioInstance; sm: PioStateMachine) {.importc: "pio_sm_claim"}

proc claimSmMask*(pio: PioInstance; smMask: set[PioStateMachine]) {.importc: "pio_claim_sm_mask".}

proc unclaim*(pio: PioInstance; sm: PioStateMachine) {.importc: "pio_sm_unclaim".}

proc claimUnusedSm*(pio: PioInstance; required: bool): int {.importc: "pio_claim_unused_sm".}

proc isClaimed*(pio: PioInstance; sm: PioStateMachine): bool {.importc: "pio_sm_is_claimed".}

proc smInit(pio: PioInstance; sm: uint; initialpc: uint; config: ptr PioSmConfig)
  {.importc: "pio_sm_init".}

proc setEnabled(pio: PioInstance; sm: PioStateMachine; enabled: bool)
  {.importc: "pio_sm_set_enabled".}

proc setSmMaskEnabled(pio: PioInstance; mask: uint32; enabled: bool)
  {.importc: "pio_set_sm_mask_enabled".}

proc restart*(pio: PioInstance; sm: PioStateMachine)
  {.importc: "pio_sm_restart".}

proc restart*(pio: PioInstance; mask: set[PioStateMachine])
  {.importc: "pio_restart_sm_mask".}

proc clkdivRestart*(pio: PioInstance; sm: PioStateMachine)
  {.importc: "pio_sm_clkdiv_restart".}

proc clkdivRestart*(pio: PioInstance; mask: set[PioStateMachine])
  {.importc: "pio_clkdiv_restart_sm_mask".}

proc enableInSync*(pio: PioInstance; mask: set[PioStateMachine])
  {.importc: "pio_enable_sm_mask_in_sync".}
{.pop}

proc setPins*(pio: PioInstance; sm: PioStateMachine; pins: set[Gpio], value: Value) =
  let v: uint32 = if value == High: uint32.high else: 0
  setPinsWithMask(pio, sm, v, cast[uint32](pins))

proc setPinDirs*(pio: PioInstance, sm: PioStateMachine, dir: bool, pins: set[Gpio]) =
  let v: uint32 = if dir: uint32.high else: 0
  setPindirsWithMask(pio, sm, v, cast[uint32](pins))

proc setPinDirs*(pio: PioInstance, sm: PioStateMachine, dir: bool, pins: Slice[Gpio]) =
  setConsecutivePindirs(pio, sm, pins.a.uint, pins.len.uint, dir)

proc init*(pio: PioInstance; sm: uint; initialpc: uint; config: PioSmConfig) =
  var configCopy = config 
  smInit(pio, sm, initialpc, configCopy.addr)

proc enable*(pio: PioInstance; sm: PioStateMachine) {.inline.} =
  pio.setEnabled(sm, true)

proc enable*(pio: PioInstance; sm: set[PioStateMachine]) {.inline.} =
  setSmMaskEnabled(pio, cast[uint32](sm), true)

proc disable*(pio: PioInstance; sm: PioStateMachine) {.inline.} =
  pio.setEnabled(sm, false)

proc disable*(pio: PioInstance; sm: set[PioStateMachine]) {.inline.} =
  setSmMaskEnabled(pio, cast[uint32](sm), false)

# FIFO API

{.push header: "hardware/pio.h".}
proc putBlocking*(pio: PioInstance; sm: PioStateMachine; data: uint32)
  {.importc: "pio_sm_put_blocking".}

proc getBlocking*(pio: PioInstance; sm: PioStateMachine): uint32
  {.importc: "pio_sm_get_blocking".}
{.pop}
