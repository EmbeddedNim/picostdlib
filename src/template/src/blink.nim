import picostdlib/[hardware/gpio, pico/time]

DefaultLedPin.gpioInit()
DefaultLedPin.gpioSetDir(Out)
while true:
  DefaultLedPin.gpioPut(High)
  sleepMs(250)
  DefaultLedPin.gpioPut(Low)
  sleepMs(250)
