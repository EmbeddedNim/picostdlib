{.push header: "hardware/xosc.h".}

proc xoscInit*() {.importc: "xosc_init".}
  ##   ! \brief  Initialise the crystal oscillator system
  ##     \ingroup hardware_xosc
  ##   
  ##    This function will block until the crystal oscillator has stabilised.
  ## ```

proc xoscDisable*() {.importc: "xosc_disable".}
  ## ```
  ##   ! \brief  Disable the Crystal oscillator
  ##     \ingroup hardware_xosc
  ##   
  ##    Turns off the crystal oscillator source, and waits for it to become unstable
  ## ```

proc xoscDormant*() {.importc: "xosc_dormant".}
  ## ```
  ##   ! \brief Set the crystal oscillator system to dormant
  ##     \ingroup hardware_xosc
  ##   
  ##    Turns off the crystal oscillator until it is woken by an interrupt. This will block and hence
  ##    the entire system will stop, until an interrupt wakes it up. This function will
  ##    continue to block until the oscillator becomes stable after its wakeup.
  ## ```

{.pop.}
