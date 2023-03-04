import picostdlib/[hardware/gpio, hardware/uart]

let uartId = uart0
const baudrate = 115200

const uartTxPin = 0.Gpio
const uartRxPin = 1.Gpio

# Set up our UART with the required speed.
discard uartInit(uartId, baudrate)

# Set the TX and RX pins by using the function select on the GPIO
# See datasheet for more information on function select
gpioSetFunction(uartTxPin, Uart)
gpioSetFunction(uartRxPin, Uart)

# Use some the various UART functions to send out data
# In a default system, printf will also output via the default UART

# Send out a character without any conversions
uartPutcRaw(uartId, 'A')

# Send out a character but do CR/LF conversions
uartPutc(uartId, 'B')

# Send out a string, with CR/LF conversions
uartPuts(uartId, " Hello, UART!\n")
