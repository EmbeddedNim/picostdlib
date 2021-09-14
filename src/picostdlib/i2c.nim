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

var i2c0* {.importC: "i2c0_inst".}: I2cInst
var i2c1* {.importC: "i2c1_inst".}: I2cInst

proc init*(i2c: var I2cInst, baudrate: cuint) {.importC: "i2c_init".}
proc deinit*(i2c: var I2cInst) {.importc: "i2c_deinit".}
proc setBaudrate*(i2c: var I2cInst, baudRate: cuint): cuint {.importc: "i2c_set_baudrate".}
proc setSlaveMode*(i2c: var I2cInst, slave: bool, address: uint8) {.importc: "i2c_set_slave_mode".}

{.pop.}
