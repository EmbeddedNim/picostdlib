import system/ansi_c

proc stdioInitAll*{.importc: "stdio_init_all", header: "<stdio.h>".}
proc stdioInitUsb*{.importC: "stdio_usb_init", header: "<stdio.h>".}
proc sleep*(ms: uint32){.importc: "sleep_ms", header: "<stdio.h>".}

proc print*(s: cstring) {.inline.} = cPrintf(s)

proc defaultTxWaitBlocking*(){.importC: "uart_default_tx_wait_blocking", header: "hardware/uart.h".}
