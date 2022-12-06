import picostdlib/[pico/stdio, hardware/gpio, pico/time]

discard stdioUsbInit()

DefaultLedPin.gpioInit()
DefaultLedPin.gpioSetDir(Out)

while true:
  DefaultLedPin.gpioPut(High)
  sleepMs(250)
  DefaultLedPin.gpioPut(Low)
  sleepMs(250)
