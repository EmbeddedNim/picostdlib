import system/ansi_c

{.push header: "<stdio.h>".}
proc stdioInitAll*{.importc: "stdio_init_all".}
  ## Initialize all of the present standard stdio types that are linked into the 
  ## binary.
  ## 
  ## Call this method once you have set up your clocks to enable the stdio 
  ## support for UART, USB and semihosting based on the presence of the 
  ## respective libraries in the binary.


proc stdioInitUsb*{.importC: "stdio_usb_init".}
  ## Explicitly initialize USB stdio and add it to the current set of stdin 
  ## drivers. 

proc sleep*(ms: uint32){.importc: "sleep_ms".}
  ## Wait for the given number of milliseconds before returning. 
  ## 
  ## Note: This procedure attempts to perform a lower power sleep (using WFE) as much as possible.
  ##
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **ms**     the number of milliseconds to sleep 

proc sleepMicroseconds*(us: uint64){.importc: "sleep_us".}
  ## Wait for the given number of microseconds before returning. 
  ## 
  ## Note: This procedure attempts to perform a lower power sleep (using WFE) as much as possible.
  ##
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **us**     the number of microseconds to sleep 


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

proc print*(s: cstring) {.inline.} = cPrintf(s)
  ## write output directly to the console (or serial console)

proc defaultTxWaitBlocking*(){.importC: "uart_default_tx_wait_blocking", header: "hardware/uart.h".}
  ## Wait for the default UART'S TX fifo to be drained. 
