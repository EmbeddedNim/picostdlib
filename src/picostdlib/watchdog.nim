{.push header: "hardware/watchdog.h".}

proc watchdogEnable*(delayms: uint32, pauseOnDebug: bool) {.importC: "watchdog_enable".}

proc watchdogUpade*() {.importC: "watchdog_update".}

proc watchdogCausedReboot*(): bool {.importC: "watchdog_caused_reboot".}

proc watchdogReboot*(pc: uint32, sp: uint32, delayms: uint32) {.importC: "watchdog_reboot".}

{.pop.}
