
## uart_inst struct does not exist
## cpp backend needs this to be defined
{.emit: "struct uart_inst {};".}


type
  UartParity* {.pure, size: sizeof(cuint).} = enum
    ## UART Parity enumeration
    None, Even, Odd

{.push header: "hardware/uart.h".}

type
  UartInst* {.importc: "uart_inst_t", bycopy.} = object
    ## Currently always a pointer to hw but it might not be in the future

let
  uart0* {.importc: "uart0".}: ptr UartInst
  uart1* {.importc: "uart1".}: ptr UartInst
  uartDefault* {.importc: "uart_default".}: ptr UartInst

  PicoDefaultUartBaudrate* {.importc: "PICO_DEFAULT_UART_BAUD_RATE".}: cuint

proc uartGetIndex*(uart: ptr UartInst): cuint {.importc: "uart_get_index".}
  ## ```
  ##   ! \brief Convert UART instance to hardware instance number
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance
  ##    \return Number of UART, 0 or 1.
  ## ```

proc uartInit*(uart: ptr UartInst; baudrate: cuint): cuint {.importc: "uart_init".}
  ## ```
  ##   ----------------------------------------------------------------------------
  ##      Setup
  ##     ! \brief Initialise a UART
  ##     \ingroup hardware_uart
  ##   
  ##    Put the UART into a known state, and enable it. Must be called before other
  ##    functions.
  ##   
  ##    \note There is no guarantee that the baudrate requested will be possible, the nearest will be chosen,
  ##    and this function will return the configured baud rate.
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param baudrate Baudrate of UART in Hz
  ##    \return Actual set baudrate
  ## ```

proc uartDeinit*(uart: ptr UartInst) {.importc: "uart_deinit".}
  ## ```
  ##   ! \brief DeInitialise a UART
  ##     \ingroup hardware_uart
  ##   
  ##    Disable the UART if it is no longer used. Must be reinitialised before
  ##    being used again.
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ## ```

proc uartSetBaudrate*(uart: ptr UartInst; baudrate: cuint): cuint {.importc: "uart_set_baudrate".}
  ## ```
  ##   ! \brief Set UART baud rate
  ##     \ingroup hardware_uart
  ##   
  ##    Set baud rate as close as possible to requested, and return actual rate selected.
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param baudrate Baudrate in Hz
  ##    \return Actual set baudrate
  ## ```

proc uartSetHwFlow*(uart: ptr UartInst; cts: bool; rts: bool) {.importc: "uart_set_hw_flow".}
  ## ```
  ##   ! \brief Set UART flow control CTS/RTS
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param cts If true enable flow control of TX  by clear-to-send input
  ##    \param rts If true enable assertion of request-to-send output by RX flow control
  ## ```

proc uartSetFormat*(uart: ptr UartInst; dataBits: cuint; stopBits: cuint; parity: UartParity) {.importc: "uart_set_format".}
  ## ```
  ##   ! \brief Set UART data format
  ##     \ingroup hardware_uart
  ##   
  ##    Configure the data format (bits etc() for the UART
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param data_bits Number of bits of data. 5..8
  ##    \param stop_bits Number of stop bits 1..2
  ##    \param parity Parity option.
  ## ```

proc uartSetIrqEnables*(uart: ptr UartInst; rxHasData: bool; txNeedsData: bool) {.importc: "uart_set_irq_enables".}
  ## ```
  ##   ! \brief Setup UART interrupts
  ##     \ingroup hardware_uart
  ##   
  ##    Enable the UART's interrupt output. An interrupt handler will need to be installed prior to calling
  ##    this function.
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param rx_has_data If true an interrupt will be fired when the RX FIFO contains data.
  ##    \param tx_needs_data If true an interrupt will be fired when the TX FIFO needs data.
  ## ```

proc uartIsEnabled*(uart: ptr UartInst): bool {.importc: "uart_is_enabled".}
  ## ```
  ##   ! \brief Test if specific UART is enabled
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \return true if the UART is enabled
  ## ```

proc uartSetFifoEnabled*(uart: ptr UartInst; enabled: bool) {.importc: "uart_set_fifo_enabled".}
  ## ```
  ##   ! \brief Enable/Disable the FIFOs on specified UART
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param enabled true to enable FIFO (default), false to disable
  ## ```

proc uartIsWritable*(uart: ptr UartInst): bool {.importc: "uart_is_writable".}
  ## ```
  ##   ! \brief Determine if space is available in the TX FIFO
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \return false if no space available, true otherwise
  ## ```

proc uartTxWaitBlocking*(uart: ptr UartInst) {.importc: "uart_tx_wait_blocking".}
  ## ```
  ##   ! \brief Wait for the UART TX fifo to be drained
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ## ```

proc uartIsReadable*(uart: ptr UartInst): bool {.importc: "uart_is_readable".}
  ## ```
  ##   ! \brief Determine whether data is waiting in the RX FIFO
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \return 0 if no data available, otherwise the number of bytes, at least, that can be read
  ##   
  ##    \note HW limitations mean this function will return either 0 or 1.
  ## ```

proc uartWriteBlocking*(uart: ptr UartInst; src: ptr uint8; len: cuint) {.importc: "uart_write_blocking".}
  ## ```
  ##   ! \brief  Write to the UART for transmission.
  ##     \ingroup hardware_uart
  ##   
  ##    This function will block until all the data has been sent to the UART
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param src The bytes to send
  ##    \param len The number of bytes to send
  ## ```

proc uartReadBlocking*(uart: ptr UartInst; dst: ptr uint8; len: cuint) {.importc: "uart_read_blocking".}
  ## ```
  ##   ! \brief  Read from the UART
  ##     \ingroup hardware_uart
  ##   
  ##    This function will block until all the data has been received from the UART
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param dst Buffer to accept received bytes
  ##    \param len The number of bytes to receive.
  ## ```

proc uartPutcRaw*(uart: ptr UartInst; c: cchar) {.importc: "uart_putc_raw".}
  ## ```
  ##   ----------------------------------------------------------------------------
  ##      UART-specific operations and aliases
  ##     ! \brief  Write single character to UART for transmission.
  ##     \ingroup hardware_uart
  ##   
  ##    This function will block until the entire character has been sent
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param c The character  to send
  ## ```

proc uartPutc*(uart: ptr UartInst; c: cchar) {.importc: "uart_putc".}
  ## ```
  ##   ! \brief  Write single character to UART for transmission, with optional CR/LF conversions
  ##     \ingroup hardware_uart
  ##   
  ##    This function will block until the character has been sent
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param c The character  to send
  ## ```

proc uartPuts*(uart: ptr UartInst; s: cstring) {.importc: "uart_puts".}
  ## ```
  ##   ! \brief  Write string to UART for transmission, doing any CR/LF conversions
  ##     \ingroup hardware_uart
  ##   
  ##    This function will block until the entire string has been sent
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param s The null terminated string to send
  ## ```

proc uartGetc*(uart: ptr UartInst): cchar {.importc: "uart_getc".}
  ## ```
  ##   ! \brief  Read a single character to UART
  ##     \ingroup hardware_uart
  ##   
  ##    This function will block until the character has been read
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \return The character read.
  ## ```

proc uartSetBreak*(uart: ptr UartInst; en: bool) {.importc: "uart_set_break".}
  ## ```
  ##   ! \brief Assert a break condition on the UART transmission.
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param en Assert break condition (TX held low) if true. Clear break condition if false.
  ## ```

proc uartSetTranslateCrlf*(uart: ptr UartInst; translate: bool) {.importc: "uart_set_translate_crlf".}
  ## ```
  ##   ! \brief Set CR/LF conversion on UART
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param translate If true, convert line feeds to carriage return on transmissions
  ## ```

proc uartDefaultTxWaitBlocking*() {.importc: "uart_default_tx_wait_blocking".}
  ## ```
  ##   ! \brief Wait for the default UART's TX FIFO to be drained
  ##     \ingroup hardware_uart
  ## ```

proc uartIsReadableWithinUs*(uart: ptr UartInst; us: uint32): bool {.importc: "uart_is_readable_within_us".}
  ## ```
  ##   ! \brief Wait for up to a certain number of microseconds for the RX FIFO to be non empty
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param us the number of microseconds to wait at most (may be 0 for an instantaneous check)
  ##    \return true if the RX FIFO became non empty before the timeout, false otherwise
  ## ```

proc uartGetDreq*(uart: ptr UartInst; isTx: bool): cuint {.importc: "uart_get_dreq".}
  ## ```
  ##   ! \brief Return the DREQ to use for pacing transfers to/from a particular UART instance
  ##     \ingroup hardware_uart
  ##   
  ##    \param uart UART instance. \ref uart0 or \ref uart1
  ##    \param is_tx true for sending data to the UART instance, false for receiving data from the UART instance
  ## ```

{.pop.}
