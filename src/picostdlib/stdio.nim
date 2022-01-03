import system/ansi_c

{.push header: "<stdio.h>".}
proc stdioInitAll*{.importc: "stdio_init_all".}
  ## Initialize all of the present standard stdio types that are linked into the 
  ## binary.
  ## 
  ## Call this method once you have set up your clocks to enable the stdio 
  ## support for UART, USB and semihosting based on the presence of the 
  ## respective libraries in the binary.


proc stdioInitUsb*: bool{.importC: "stdio_usb_init".}
  ## Explicitly initialize USB stdio and add it to the current set of stdin 
  ## drivers. 

proc usbConnected*: bool {.importC: "stdio_usb_connected".}
  ## Returns true if USB uart is connected.
  

proc getCharWithTimeout*(timeout: uint32): char {.importC: "getchar_timeout_us".} 
  ## Return a character from stdin if there is one available within a timeout.
  ## 
  ## **Parameters:**
  ## 
  ## ===========  ====== 
  ## **timeout**   the timeout in microseconds, or 0 to not wait for a character if none available.
  ## ===========  ======
  ## 
  ## **Returns:** the character from 0-255 or PICO_ERROR_TIMEOUT if timeout occurs  
{.pop.}


proc blockUntilUsbConnected*() =
  ## Blocks until the usb is connected, useful if reliant on USB interface.
  while not usbConnected(): discard

proc print*(s: cstring) {.inline.} = cPrintf(s)
  ## write output directly to the console (or serial console)

proc print*(s: string) =
  print(cstring s)
  print(cstring "\n")

proc defaultTxWaitBlocking*(){.importC: "uart_default_tx_wait_blocking", header: "hardware/uart.h".}
  ## Wait for the default UART'S TX fifo to be drained. 
