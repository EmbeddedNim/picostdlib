{.push header: "hardware/watchdog.h".}

proc watchdogEnable*(delayMs: uint32, pauseOnDebug: bool) {.importC: "watchdog_enable".}

proc watchdogUpade*() {.importC: "watchdog_update".}

proc watchdogCauseReboot*(): bool {.importC: "watchdog_caused_reboot".}

{.pop.}
