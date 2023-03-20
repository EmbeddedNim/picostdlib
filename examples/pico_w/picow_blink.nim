import picostdlib/[pico/time, pico/cyw43_arch]

if cyw43ArchInit() == PicoErrorNone:
  while true:
    cyw43ArchGpioPut(Cyw43WlGpioLedPin, High)
    sleepMs(250)
    cyw43ArchGpioPut(Cyw43WlGpioLedPin, Low)
    sleepMs(250)
