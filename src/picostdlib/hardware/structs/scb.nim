import ../base, ../regs/m0plus
export base, m0plus

{.push header: "hardware/structs/scb.h".}

type
  Armv6mScb* {.importc: "armv6m_scb_t".} = object
    cpuid*: IoRo32
    icsr*: IoRw32
    vtor*: IoRw32
    aircr*: IoRw32
    scr*: IoRw32

let scbHw* {.importc: "scb_hw".}: ptr Armv6mScb

{.pop.}
