import system/ansi_c

{.push header: "<stdio.h>".}
proc stdioInitAll*{.importc: "stdio_init_all".}
proc stdioInitUsb*{.importC: "stdio_usb_init".}
proc sleep*(ms: uint32){.importc: "sleep_ms".}

proc getCharWithTimeout*(timeout: uint32): char {.importC: "getchar_timeout_us".}
{.pop.}


proc print*(s: cstring) {.inline.} = cPrintf(s)


proc defaultTxWaitBlocking*(){.importC: "uart_default_tx_wait_blocking", header: "hardware/uart.h".}
