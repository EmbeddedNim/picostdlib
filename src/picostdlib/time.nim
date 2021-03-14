type 
  AbsoluteTime* {.importc: "absolute_time_t", header: "pico/types.h".} = object
    time*{.importC: "_private_us_since_boot".}: uint64
  DateTime* = object
    year*: 0u16..4095u16
    month*: 1u8..12u8
    day*: 1u8..31u8
    dotw*: 0u8..6u8
    hour*: 0u8..23u8
    min*, sec*: 0u8..59u8

proc getTime*: AbsoluteTime {.importC:"get_absolute_time", header: "pico/time.h".}