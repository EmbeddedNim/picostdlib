import picostdlib/[pico/time, pico/cyw43_arch]

if cyw43ArchInit() == PicoErrorNone:
  while true:
    cyw43ArchGpioPut(CYW43_WL_GPIO_LED_PIN, true)
    sleepMs(250)
    cyw43ArchGpioPut(CYW43_WL_GPIO_LED_PIN, false)
    sleepMs(250)
