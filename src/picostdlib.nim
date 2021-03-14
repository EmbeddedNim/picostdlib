import system/ansi_c

proc stdioInitAll*{.importc:"stdio_init_all", header: "<stdio.h>".}

proc sleep*(ms: uint32){.importc:"sleep_ms", header: "<stdio.h>".}

proc print*(s: string | cstring) = 
  cPrintf(s)
  cPrintf("\n")