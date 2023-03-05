import picostdlib
import picostdlib/[hardware/pll, hardware/clocks]

stdioInitAll()

echo "Hello gpout"

# Output clk_sys / 10 to gpio 21, etc...
clockGpioInit(Gpio(21), ClocksClkGpoutCtrlAuxSrc.ClkSys, 10)
clockGpioInit(Gpio(23), ClocksClkGpoutCtrlAuxSrc.ClkUsb, 10)
clockGpioInit(Gpio(24), ClocksClkGpoutCtrlAuxSrc.ClkAdc, 10)
clockGpioInit(Gpio(25), ClocksClkGpoutCtrlAuxSrc.ClkRtc, 10)
