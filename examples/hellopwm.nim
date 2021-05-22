import picostdlib/[pwm]
let
  pin0 = 0.Gpio
  pin1 = 1.Gpio
pin0.setFunction(PWM)
pin1.setFunction(PWM)

let sliceNum = pin0.toSliceNum()

sliceNum.setWrap(3)
sliceNum.setChanLevel(A, 1u16)
sliceNum.setChanLevel(B, 3u16)
sliceNum.setEnabled(true)
