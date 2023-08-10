import picostdlib
import picostdlib/hardware/pwm

# Output PWM signals on pins 0 and 1

const
  pin0 = Gpio(0)
  pin1 = Gpio(1)

# Tell GPIO 0 and 1 they are allocated to the PWM
pin0.setFunction(Pwm)
pin1.setFunction(Pwm)

# Find out which PWM slice is connected to GPIO 0 (it's slice 0)
const sliceNum = pin0.toPwmSliceNum()

# Set period of 4 cycles (0 to 3 inclusive)
sliceNum.pwmSetWrap(3)

# Set channel A output high for one cycle before dropping
sliceNum.pwmSetChanLevel(A, 1)

# Set initial B output high for three cycles before dropping
sliceNum.pwmSetChanLevel(B, 3)

# Set the PWM running
sliceNum.pwmSetEnabled(true)

# Note we could also use gpio.pwmSetLevel(x) which looks up the
# correct slice and channel for a given GPIO.
