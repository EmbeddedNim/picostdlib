import picostdlib/[hardware/pwm]

# Output PWM signals on pins 0 and 1

let
  pin0 = 0.Gpio
  pin1 = 1.Gpio

# Tell GPIO 0 and 1 they are allocated to the PWM
pin0.gpioSetFunction(PWM)
pin1.gpioSetFunction(PWM)

# Find out which PWM slice is connected to GPIO 0 (it's slice 0)
let sliceNum = pin0.pwmGpioToSliceNum()

# Set period of 4 cycles (0 to 3 inclusive)
sliceNum.pwmSetWrap(3)

# Set channel A output high for one cycle before dropping
sliceNum.pwmSetChanLevel(A, 1)

# Set initial B output high for three cycles before dropping
sliceNum.pwmSetChanLevel(B, 3)

# Set the PWM running
sliceNum.pwmSetEnabled(true)

# Note we could also use pwmSetGpioLevel(gpio, x) which looks up the
# correct slice and channel for a given GPIO.
