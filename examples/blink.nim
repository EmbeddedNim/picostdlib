import picostdlib/[hardware/gpio, pico/time]

gpioInit(DefaultLedPin)
gpioSetDir(DefaultLedPin, Out)

while true:
  gpioPut(DefaultLedPin, High)
  sleepMs(250)
  gpioPut(DefaultLedPin, Low)
  sleepMs(250)
