
## spi_inst struct does not exist
## cpp backend needs this to be defined
{.emit: "struct spi_inst {};".}


type
  SpiClockPhase* {.pure, size: sizeof(cuint).} = enum
    ## Enumeration of SPI CPHA (clock phase) values.
    Phase0, Phase1

  SpiClockPolarity* {.pure, size: sizeof(cuint).} = enum
    ## Enumeration of SPI CPOL (clock polarity) values.
    Pol0, Pol1

  SpiOrder* {.pure, size: sizeof(cuint).} = enum
    ## Enumeration of SPI bit-order values.
    LsbFirst, MsbFirst

{.push header: "hardware/spi.h".}

type
  SpiInst* {.importc: "spi_inst_t", bycopy.} = object
    ## Opaque type representing an SPI instance.

let
  spi0* {.importc: "spi0".}: ptr SpiInst
  spi1* {.importc: "spi1".}: ptr SpiInst
  spiDefault* {.importc: "spi_default".}: ptr SpiInst

proc spiInit*(spi: ptr SpiInst; baudrate: cuint): cuint {.importc: "spi_init".}
  ## ```
  ##   ! \brief Initialise SPI instances
  ##     \ingroup hardware_spi
  ##    Puts the SPI into a known state, and enable it. Must be called before other
  ##    functions.
  ##   
  ##    \note There is no guarantee that the baudrate requested can be achieved exactly; the nearest will be chosen
  ##    and returned
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param baudrate Baudrate requested in Hz
  ##    \return the actual baud rate set
  ## ```


proc spiDeinit*(spi: ptr SpiInst) {.importc: "spi_deinit".}
  ## ```
  ##   ! \brief Deinitialise SPI instances
  ##     \ingroup hardware_spi
  ##    Puts the SPI into a disabled state. Init will need to be called to reenable the device
  ##    functions.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ## ```

proc spiSetBaudrate*(spi: ptr SpiInst; baudrate: cuint): cuint {.importc: "spi_set_baudrate".}
  ## ```
  ##   ! \brief Set SPI baudrate
  ##     \ingroup hardware_spi
  ##   
  ##    Set SPI frequency as close as possible to baudrate, and return the actual
  ##    achieved rate.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param baudrate Baudrate required in Hz, should be capable of a bitrate of at least 2Mbps, or higher, depending on system clock settings.
  ##    \return The actual baudrate set
  ## ```

proc spiGetBaudrate*(spi: ptr SpiInst): cuint {.importc: "spi_get_baudrate".}
  ## ```
  ##   ! \brief Get SPI baudrate
  ##     \ingroup hardware_spi
  ##   
  ##    Get SPI baudrate which was set by \see spi_set_baudrate
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \return The actual baudrate set
  ## ```

proc spiGetIndex*(spi: ptr SpiInst): cuint {.importc: "spi_get_index".}
  ## ```
  ##   ! \brief Convert SPI instance to hardware instance number
  ##     \ingroup hardware_spi
  ##   
  ##    \param spi SPI instance
  ##    \return Number of SPI, 0 or 1.
  ## ```


proc spiSetFormat*(spi: ptr SpiInst; dataBits: cuint(4) .. cuint(16); cpol: SpiClockPolarity; cpha: SpiClockPhase; order: SpiOrder) {.importc: "spi_set_format".}
  ## ```
  ##   ! \brief Configure SPI
  ##     \ingroup hardware_spi
  ##   
  ##    Configure how the SPI serialises and deserialises data on the wire
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param data_bits Number of data bits per transfer. Valid values 4..16.
  ##    \param cpol SSPCLKOUT polarity, applicable to Motorola SPI frame format only.
  ##    \param cpha SSPCLKOUT phase, applicable to Motorola SPI frame format only
  ##    \param order Must be SPI_MSB_FIRST, no other values supported on the PL022
  ## ```

proc spiSetSlave*(spi: ptr SpiInst; slave: bool) {.importc: "spi_set_slave".}
  ## ```
  ##   ! \brief Set SPI master/slave
  ##     \ingroup hardware_spi
  ##   
  ##    Configure the SPI for master- or slave-mode operation. By default,
  ##    spi_init() sets master-mode.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param slave true to set SPI device as a slave device, false for master.
  ## ```

proc spiIsWritable*(spi: ptr SpiInst): bool {.importc: "spi_is_writable".}
  ## ```
  ##   ----------------------------------------------------------------------------
  ##      Generic input/output
  ##     ! \brief Check whether a write can be done on SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \return false if no space is available to write. True if a write is possible
  ## ```

proc spiIsReadable*(spi: ptr SpiInst): bool {.importc: "spi_is_readable".}
  ## ```
  ##   ! \brief Check whether a read can be done on SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \return true if a read is possible i.e. data is present
  ## ```

proc spiIsBusy*(spi: ptr SpiInst): bool {.importc: "spi_is_busy".}
  ## ```
  ##   ! \brief Check whether SPI is busy
  ##     \ingroup hardware_spi
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \return true if SPI is busy
  ## ```

proc spiWriteReadBlocking*(spi: ptr SpiInst; src, dst: ptr uint8; len: csize_t): cint {.importc: "spi_write_read_blocking".}
  ## ```
  ##   ! \brief Write/Read to/from an SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    Write \p len bytes from \p src to SPI. Simultaneously read \p len bytes from SPI to \p dst.
  ##    Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param src Buffer of data to write
  ##    \param dst Buffer for read data
  ##    \param len Length of BOTH buffers
  ##    \return Number of bytes written/read
  ## ```

proc spiWriteBlocking*(spi: ptr SpiInst; src: ptr uint8; len: csize_t): cint {.importc: "spi_write_blocking".}
  ## ```
  ##   ! \brief Write to an SPI device, blocking
  ##     \ingroup hardware_spi
  ##   
  ##    Write \p len bytes from \p src to SPI, and discard any data received back
  ##    Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param src Buffer of data to write
  ##    \param len Length of \p src
  ##    \return Number of bytes written/read
  ## ```

proc spiReadBlocking*(spi: ptr SpiInst; repeatedTxData: uint8; dst: ptr uint8; len: csize_t): cint {.importc: "spi_read_blocking".}
  ## ```
  ##   ! \brief Read from an SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    Read \p len bytes from SPI to \p dst.
  ##    Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  ##    \p repeated_tx_data is output repeatedly on TX as data is read in from RX.
  ##    Generally this can be 0, but some devices require a specific value here,
  ##    e.g. SD cards expect 0xff
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param repeated_tx_data Buffer of data to write
  ##    \param dst Buffer for read data
  ##    \param len Length of buffer \p dst
  ##    \return Number of bytes written/read
  ## ```

proc spiWrite16Read16Blocking*(spi: ptr SpiInst; src: ptr uint16; dst: ptr uint16; len: csize_t): cint {.importc: "spi_write16_read16_blocking".}
  ## ```
  ##   ! \brief Write/Read half words to/from an SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    Write \p len halfwords from \p src to SPI. Simultaneously read \p len halfwords from SPI to \p dst.
  ##    Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  ##   
  ##    \note SPI should be initialised with 16 data_bits using \ref spi_set_format first, otherwise this function will only read/write 8 data_bits.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param src Buffer of data to write
  ##    \param dst Buffer for read data
  ##    \param len Length of BOTH buffers in halfwords
  ##    \return Number of halfwords written/read
  ## ```

proc spiWrite16Blocking*(spi: ptr SpiInst; src: ptr uint16; len: csize_t): cint {.importc: "spi_write16_blocking".}
  ## ```
  ##   ! \brief Write to an SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    Write \p len halfwords from \p src to SPI. Discard any data received back.
  ##    Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  ##   
  ##    \note SPI should be initialised with 16 data_bits using \ref spi_set_format first, otherwise this function will only write 8 data_bits.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param src Buffer of data to write
  ##    \param len Length of buffers
  ##    \return Number of halfwords written/read
  ## ```

proc spiRead16Blocking*(spi: ptr SpiInst; repeatedTxData: uint16; dst: ptr uint16; len: csize_t): cint {.importc: "spi_read16_blocking".}
  ## ```
  ##   ! \brief Read from an SPI device
  ##     \ingroup hardware_spi
  ##   
  ##    Read \p len halfwords from SPI to \p dst.
  ##    Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  ##    \p repeated_tx_data is output repeatedly on TX as data is read in from RX.
  ##    Generally this can be 0, but some devices require a specific value here,
  ##    e.g. SD cards expect 0xff
  ##   
  ##    \note SPI should be initialised with 16 data_bits using \ref spi_set_format first, otherwise this function will only read 8 data_bits.
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param repeated_tx_data Buffer of data to write
  ##    \param dst Buffer for read data
  ##    \param len Length of buffer \p dst in halfwords
  ##    \return Number of halfwords written/read
  ## ```

proc spiGetDreq*(spi: ptr SpiInst; isTx: bool): cuint {.importc: "spi_get_dreq".}
  ## ```
  ##   ! \brief Return the DREQ to use for pacing transfers to/from a particular SPI instance
  ##     \ingroup hardware_spi
  ##   
  ##    \param spi SPI instance specifier, either \ref spi0 or \ref spi1
  ##    \param is_tx true for sending data to the SPI instance, false for receiving data from the SPI instance
  ## ```

{.pop.}
