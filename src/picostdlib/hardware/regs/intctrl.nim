type
  InterruptNumber* {.pure.} = enum
    TimerIrq0 = 0.cuint
    TimerIrq1 = 1.cuint
    TimerIrq2 = 2.cuint
    TimerIrq3 = 3.cuint
    PwmIrqWrap = 4.cuint
    UsbCtrlIrq = 5.cuint
    XipIrq = 6.cuint
    Pio0Irq0 = 7.cuint
    Pio0Irq1 = 8.cuint
    Pio1Irq0 = 9.cuint
    Pio1Irq1 = 10.cuint
    DmaIrq0 = 11.cuint
    DmaIrq1 = 12.cuint
    IoIrqBank0 = 13.cuint
    IoIrqQSpi = 14.cuint
    SIoIrqProc0 = 15.cuint
    SIoIrqProc1 = 16.cuint
    ClocksIrq = 17.cuint
    Spi0Irq = 18.cuint
    Spi1Irq = 19.cuint
    Uart0Irq = 20.cuint
    Uart1Irq = 21.cuint
    AdcIrqFifo = 22.cuint
    I2C0Irq = 23.cuint
    I2C1Irq = 24.cuint
    RtcIrq = 25.cuint
    User0Irq
    User1Irq
    User2Irq
    User3Irq
    User4Irq
    User5Irq
