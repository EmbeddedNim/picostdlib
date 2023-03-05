{.push header: "hardware/structs/uart.h".}

type
  UartHw* {.importc: "uart_hw_t".} = object

let
  uart0Hw* {.importc: "uart0_hw".}: ptr UartHw
  uart1Hw* {.importc: "uart1_hw".}: ptr UartHw

{.pop.}
