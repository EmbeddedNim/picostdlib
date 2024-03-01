import picostdlib
import picostdlib/hardware/resets

stdioInitAll()

echo "Hello, reset!"

# Put the PWM block into reset
resetBlock(RESETS_RESET_PWM_BITS)

# And bring it out
unresetBlockWait(RESETS_RESET_PWM_BITS)

# Put the PWM and RTC block into reset
resetBlock(RESETS_RESET_PWM_BITS or RESETS_RESET_RTC_BITS)

# Wait for both to come out of reset
unresetBlockWait(RESETS_RESET_PWM_BITS or RESETS_RESET_RTC_BITS)
