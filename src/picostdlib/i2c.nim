type
  I2Hw* {.importC: "i2c_hw_t", header: "hardware/structs/i2c.h".} = object
    con*, tar*, sar*: uint32
    pad0: uint32
    dataCmd*, ssSclHcnt*, ssSclLcnt*, fsSclHcnt*, fsSclLcnt*: uint32
    pad1: array[2, uint32]
    intrStat*, intrMask*, rawIntrStat*, rxTl*, txTl*, clrIntr*: uint32
    clrRxUnder*, clrRxOver*, clTxOver*, clRdReq*, clrTxAbrt*, clrRxDone*: uint32
    clrActivity*, clrStopDet*, clrStartDet*, clrGenCall*: uint32
    enable*, status*: uint32
    txFlr*, rxFlr*: uint32
    sdaHold*: uint32
    txAbortSource*: uint32
    slvDataNackOnly*: uint32
    dmaCr*, dmaTdlr*, dmaRdlr*: uint32
    sdaSetup*: uint32
    ackGeneralCall*, enableStatus*, fkSpkLen*: uint32
    pad2: uint32
    clrRestartDet*: uint32
{.push header: "hardware/i2c.h".}
type
  I2cInst* {.importc: "i2c_inst_t".} = object
    hw*: ptr I2Hw
    restartOnNext*: bool

  I2cAddress* = distinct range[0'u8 .. 127'u8]

var i2c0* {.importC: "i2c0_inst".}: I2cInst
var i2c1* {.importC: "i2c1_inst".}: I2cInst

proc init*(i2c: var I2cInst, baudrate: cuint) {.importC: "i2c_init".}
proc deinit*(i2c: var I2cInst) {.importc: "i2c_deinit".}
proc setBaudrate*(i2c: var I2cInst, baudRate: cuint): cuint {.importc: "i2c_set_baudrate".}
proc setSlaveMode*(i2c: var I2cInst, slave: bool, address: uint8) {.importc: "i2c_set_slave_mode".}

proc writeBlocking*(i2c: var I2cInst, address: uint8, data: pointer, len: csize_t,
    noStop: bool){.importc: "i2c_write_blocking".}

proc readBlocking*(i2c: var I2cInst, address: uint8, dest: pointer, size: csize_t,
    noStop: bool): cint {.importC: "i2c_read_blocking".}

{.pop.}

import picostdlib/[gpio]
template setupI2c*(blokk: I2cInst, psda, pscl: Gpio, freq: int, pull = true) =
#sugar setup for i2c:
#blokk= block i2c0 / i2c1 (see pinout)
#sda/pscl = the pins tou want use (ex: 2.Gpio, 3.Gpio) I do not recommend the use of 0.Gpio, 1.Gpio
#freq = is the working frequency of the i2c device (see device manual; ex: 100000)
#pull = use or not to use pullup (default = ture)
  var i2cx = blokk
  i2cx.init(freq)
  psda.setFunction(I2C)
  pscl.setFunction(I2C)
  if pull == true:
      psda.pullup()
      pscl.pullup()
  else:
      psda.pulldown()
      pscl.pulldown()

proc writeBlocking*(
    i2c: var I2cInst,
    address: I2cAddress,
    data: openArray[uint8],
    noStop: bool = false
  ) =
  ## Write bytes to I2C bus.
  ## If `noStop` is `true`, master retains control of the bus at the end of
  ## the transfer.
  writeBlocking(i2c, address.uint8, data[0].unsafeAddr, data.len.uint, noStop)

proc readBlocking*(
    i2c: var I2cInst,
    address: I2cAddress,
    numBytes: Natural,
    noStop: bool = false
  ): seq[uint8] =
  ## Read `numBytes` bytes from I2C bus and return a seq containing the bytes
  ## that were read. In case of error return a 0-length seq. If `noStop` is
  ## `true`, master retains control of the bus at the end of the transfer.

  result.setLen(numBytes)
  let n = readBlocking(i2c, address.uint8, result[0].addr, numBytes.uint, noStop)
  result.setLen(max(0, n))

proc readBlocking*[N: Natural](
    i2c: var I2cInst,
    address: I2cAddress,
    dest: var array[N, uint8],
    noStop: bool = false
  ): int =
  ## Fill the array `dest` with bytes read from I2C bus. Return the number of
  ## bytes that were read successfully. Negative values are error codes (refer
  ## to Pico SDK documentation). In case of error return a 0-length seq. If
  ## `noStop` is `true`, master retains control of the bus at the end of the
  ## transfer.
  result = readBlocking(i2c, address.uint8, dest[0].addr, dest.len.uint, noStop)
