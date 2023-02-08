import structs/i2c
import ../pico/types

{.push header: "hardware/i2c.h".}

type
  I2cInst* {.importc: "struct i2c_inst".} = object
    hw* {.importc.}: ptr I2cHw
    restartOnNext* {.importc: "restart_on_next".}: bool

  I2cAddress* = distinct range[0'u8 .. 127'u8]

var
  i2c0Inst* {.importc: "i2c0_inst".}: I2cInst
  i2c1Inst* {.importc: "i2c1_inst".}: I2cInst

let
  i2c0* {.importc: "i2c0".}: ptr I2cInst
  i2c1* {.importc: "i2c1".}: ptr I2cInst
  i2cDefault* {.importc: "i2c_default".}: ptr I2cInst

proc i2cInit*(i2c: ptr I2cInst, baudrate: cuint): cuint {.importc: "i2c_init".}
  ## ```
  ##   ! \brief   Initialise the I2C HW block
  ##     \ingroup hardware_i2c
  ##   
  ##    Put the I2C hardware into a known state, and enable it. Must be called
  ##    before other functions. By default, the I2C is configured to operate as a
  ##    master.
  ##   
  ##    The I2C bus frequency is set as close as possible to requested, and
  ##    the actual rate set is returned
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param baudrate Baudrate in Hz (e.g. 100kHz is 100000)
  ##    \return Actual set baudrate
  ## ```

proc i2cDeinit*(i2c: ptr I2cInst) {.importc: "i2c_deinit".}
  ## ```
  ##   ! \brief   Disable the I2C HW block
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##   
  ##    Disable the I2C again if it is no longer used. Must be reinitialised before
  ##    being used again.
  ## ```

proc i2cSetBaudrate*(i2c: ptr I2cInst, baudrate: cuint): cuint {.importc: "i2c_set_baudrate".}
  ## ```
  ##   ! \brief  Set I2C baudrate
  ##     \ingroup hardware_i2c
  ##   
  ##    Set I2C bus frequency as close as possible to requested, and return actual
  ##    rate set.
  ##    Baudrate may not be as exactly requested due to clocking limitations.
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param baudrate Baudrate in Hz (e.g. 100kHz is 100000)
  ##    \return Actual set baudrate
  ## ```

proc i2cSetSlaveMode*(i2c: ptr I2cInst, slave: bool, address: I2cAddress) {.importc: "i2c_set_slave_mode".}
  ## ```
  ##   ! \brief  Set I2C port to slave mode
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param slave true to use slave mode, false to use master mode
  ##    \param addr If \p slave is true, set the slave address to this value
  ## ```

proc i2cHwIndex*(i2c: ptr I2cInst): cuint {.importc: "i2c_hw_index".}
  ## ```
  ##   ! \brief Convert I2C instance to hardware instance number
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c I2C instance
  ##    \return Number of I2C, 0 or 1.
  ## ```

proc i2cGetHw*(i2c: ptr I2cInst): ptr I2cHw {.importc: "i2c_get_hw".}

proc i2cGetInstance*(instance: cuint): ptr I2cInst {.importc: "i2c_get_instance".}

proc i2cWriteBlockingUntil*(i2c: ptr I2cInst; address: I2cAddress; src: ptr uint8; len: csize_t; noStop: bool; until: AbsoluteTime): cint {.importc: "i2c_write_blocking_until".}
  ## ```
  ##   ! \brief Attempt to write specified number of bytes to address, blocking until the specified absolute time is reached.
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param addr 7-bit address of device to write to
  ##    \param src Pointer to data to send
  ##    \param len Length of data in bytes to send
  ##    \param nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  ##              and the next transfer will begin with a Restart rather than a Start.
  ##    \param until The absolute time that the block will wait until the entire transaction is complete. Note, an individual timeout of
  ##              this value divided by the length of data is applied for each byte transfer, so if the first or subsequent
  ##              bytes fails to transfer within that sub timeout, the function will return with an error.
  ##   
  ##    \return Number of bytes written, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
  ## ```

proc i2cReadBlockingUntil*(i2c: ptr I2cInst; address: I2cAddress; dst: ptr uint8; len: csize_t; noStop: bool; until: AbsoluteTime): cint {.importc: "i2c_read_blocking_until".}
  ## ```
  ##   ! \brief  Attempt to read specified number of bytes from address, blocking until the specified absolute time is reached.
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param addr 7-bit address of device to read from
  ##    \param dst Pointer to buffer to receive data
  ##    \param len Length of data in bytes to receive
  ##    \param nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  ##              and the next transfer will begin with a Restart rather than a Start.
  ##    \param until The absolute time that the block will wait until the entire transaction is complete.
  ##    \return Number of bytes read, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
  ## ```

proc i2cWriteTimeoutUs*(i2c: ptr I2cInst; address: I2cAddress; src: ptr uint8; len: csize_t; noStop: bool; timeoutUs: cuint): cint {.importc: "i2c_write_timeout_us".}
  ## ```
  ##   ! \brief Attempt to write specified number of bytes to address, with timeout
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param addr 7-bit address of device to write to
  ##    \param src Pointer to data to send
  ##    \param len Length of data in bytes to send
  ##    \param nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  ##              and the next transfer will begin with a Restart rather than a Start.
  ##    \param timeout_us The time that the function will wait for the entire transaction to complete. Note, an individual timeout of
  ##              this value divided by the length of data is applied for each byte transfer, so if the first or subsequent
  ##              bytes fails to transfer within that sub timeout, the function will return with an error.
  ##   
  ##    \return Number of bytes written, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
  ## ```

proc i2cReadTimeoutUs*(i2c: ptr I2cInst; address: I2cAddress; dst: ptr uint8; len: csize_t; noStop: bool; timeoutUs: cuint): cint {.importc: "i2c_read_timeout_us".}
  ## ```
  ##   ! \brief  Attempt to read specified number of bytes from address, with timeout
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param addr 7-bit address of device to read from
  ##    \param dst Pointer to buffer to receive data
  ##    \param len Length of data in bytes to receive
  ##    \param nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  ##              and the next transfer will begin with a Restart rather than a Start.
  ##    \param timeout_us The time that the function will wait for the entire transaction to complete
  ##    \return Number of bytes read, or PICO_ERROR_GENERIC if address not acknowledged, no device present, or PICO_ERROR_TIMEOUT if a timeout occurred.
  ## ```

proc i2cWriteBlocking*(i2c: ptr I2cInst, address: I2cAddress, data: ptr uint8, len: csize_t, noStop: bool): cint {.importc: "i2c_write_blocking".}
  ## ```
  ##   ! \brief Attempt to write specified number of bytes to address, blocking
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param addr 7-bit address of device to write to
  ##    \param src Pointer to data to send
  ##    \param len Length of data in bytes to send
  ##    \param nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  ##              and the next transfer will begin with a Restart rather than a Start.
  ##    \return Number of bytes written, or PICO_ERROR_GENERIC if address not acknowledged, no device present.
  ## ```

proc i2cReadBlocking*(i2c: ptr I2cInst, address: I2cAddress, dest: ptr uint8, size: csize_t, noStop: bool): cint {.importc: "i2c_read_blocking".}
  ## ```
  ##   ! \brief  Attempt to read specified number of bytes from address, blocking
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param addr 7-bit address of device to read from
  ##    \param dst Pointer to buffer to receive data
  ##    \param len Length of data in bytes to receive
  ##    \param nostop  If true, master retains control of the bus at the end of the transfer (no Stop is issued),
  ##              and the next transfer will begin with a Restart rather than a Start.
  ##    \return Number of bytes read, or PICO_ERROR_GENERIC if address not acknowledged or no device present.
  ## ```

proc i2cGetWriteAvailable*(i2c: ptr I2cInst): cuint {.importc: "i2c_get_write_available".}
  ## ```
  ##   ! \brief Determine non-blocking write space available
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \return 0 if no space is available in the I2C to write more data. If return is nonzero, at
  ##    least that many bytes can be written without blocking.
  ## ```

proc i2cGetReadAvailable*(i2c: ptr I2cInst): cuint {.importc: "i2c_get_read_available".}
  ## ```
  ##   ! \brief Determine number of bytes received
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \return 0 if no data available, if return is nonzero at
  ##    least that many bytes can be read without blocking.
  ## ```

proc i2cWriteRawBlocking*(i2c: ptr I2cInst; src: ptr uint8; len: csize_t) {.importc: "i2c_write_raw_blocking".}
  ## ```
  ##   ! \brief Write direct to TX FIFO
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param src Data to send
  ##    \param len Number of bytes to send
  ##   
  ##    Writes directly to the I2C TX FIFO which is mainly useful for
  ##    slave-mode operation.
  ## ```

proc i2cReadRawBlocking*(i2c: ptr I2cInst; dst: ptr uint8; len: csize_t) {.importc: "i2c_read_raw_blocking".}
  ## ```
  ##   ! \brief Read direct from RX FIFO
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param dst Buffer to accept data
  ##    \param len Number of bytes to read
  ##   
  ##    Reads directly from the I2C RX FIFO which is mainly useful for
  ##    slave-mode operation.
  ## ```

proc i2cReadByteRaw*(i2c: ptr I2cInst): uint8 {.importc: "i2c_read_byte_raw".}
  ## \brief Pop a byte from I2C Rx FIFO.
  ## \ingroup hardware_i2c
  ##
  ## This function is non-blocking and assumes the Rx FIFO isn't empty.
  ##
  ## \param i2c I2C instance.
  ## \return uint8_t Byte value.

proc i2cWriteByteRaw*(i2c: ptr I2cInst; value: uint8) {.importc: "i2c_write_byte_raw".}
  ## \brief Push a byte into I2C Tx FIFO.
  ## \ingroup hardware_i2c
  ##
  ## This function is non-blocking and assumes the Tx FIFO isn't full.
  ##
  ## \param i2c I2C instance.
  ## \param value Byte value.

proc i2cGetDreq*(i2c: ptr I2cInst; isTx: bool): cuint {.importc: "i2c_get_dreq".}
  ## ```
  ##   ! \brief Return the DREQ to use for pacing transfers to/from a particular I2C instance
  ##     \ingroup hardware_i2c
  ##   
  ##    \param i2c Either \ref i2c0 or \ref i2c1
  ##    \param is_tx true for sending data to the I2C instance, false for receiving data from the I2C instance
  ## ```

{.pop.}


## Nim helpers

import gpio

template i2cSetupNim*(blokk: ptr I2cInst, pSda, pScl: Gpio, freq: uint, pull = true) =
  #sugar setup for i2c:
  #blokk= block i2c0 / i2c1 (see pinout)
  #pSda/pScl = the pins you want use (ex: 2.Gpio, 3.Gpio) I do not recommend the use of 0.Gpio, 1.Gpio
  #freq = is the working frequency of the i2c device (see device manual; ex: 100000)
  #pull = use or not to use pullup (default = true)
  var i2cx = blokk
  i2cx.i2cInit(freq)
  pSda.gpioSetFunction(GpioFunction.I2C)
  pScl.gpioSetFunction(GpioFunction.I2C)
  if pull:
    pSda.gpioPullUp()
    pScl.gpioPullUp()
  else:
    pSda.gpioPullDown()
    pScl.gpioPullDown()

proc i2cWriteBlockingNim*(
    i2c: ptr I2cInst,
    address: I2cAddress,
    data: var openArray[uint8],
    noStop: bool = false
  ): int =
  ## Write bytes to I2C bus.
  ## If `noStop` is `true`, master retains control of the bus at the end of
  ## the transfer.
  result = i2cWriteBlocking(i2c, address, data[0].addr, data.len.uint, noStop)

proc i2cReadBlockingNim*(
    i2c: ptr I2cInst,
    address: I2cAddress,
    numBytes: uint,
    noStop: bool = false
  ): seq[uint8] =
  ## Read `numBytes` bytes from I2C bus and return a seq containing the bytes
  ## that were read. In case of error return a 0-length seq. If `noStop` is
  ## `true`, master retains control of the bus at the end of the transfer.

  result.setLen(numBytes)
  let n = i2cReadBlocking(i2c, address, result[0].addr, numBytes.uint, noStop)
  result.setLen(max(0, n))

proc i2cReadBlockingNim*[N: Natural](
    i2c: ptr I2cInst,
    address: I2cAddress,
    dest: var array[N, uint8],
    noStop: bool = false
  ): int =
  ## Fill the array `dest` with bytes read from I2C bus. Return the number of
  ## bytes that were read successfully. Negative values are error codes (refer
  ## to Pico SDK documentation). In case of error return a 0-length seq. If
  ## `noStop` is `true`, master retains control of the bus at the end of the
  ## transfer.
  result = i2cReadBlocking(i2c, address, dest[0].addr, N.uint, noStop)

