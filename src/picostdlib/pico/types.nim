{.push header: "pico/types.h".}

when defined(NDEBUG):
  type
    AbsoluteTime* {.importc: "absolute_time_t".} = uint64
else:
  type
    AbsoluteTime* {.importc: "absolute_time_t".} = object
      ## the absolute time (now) of the hardware timer
      time*{.importc: "_private_us_since_boot".}: uint64

type
  Datetime* {.importc: "datetime_t".} = object
    # Structure containing date and time information
    # When setting an RTC alarm, set a field to -1 tells
    # the RTC to not match on this field
    year* {.importc.}: int16  # 0..4095
    month* {.importc.}: int8  # 1..12, 1 is January
    day* {.importc.}: int8    # 1..28,29,30,31 depending on month
    dotw* {.importc.}: int8   # 0..6, 0 is Sunday
    hour* {.importc.}: int8   # 0..23
    min* {.importc.}: int8    # 0..59
    sec* {.importc.}: int8    # 0..59

  # Datetime* = object
  #   year*: 0u16..4095u16
  #   month*: 1u8..12u8
  #   day*: 1u8..31u8
  #   dotw*: 0u8..6u8
  #   hour*: 0u8..23u8
  #   min*, sec*: 0u8..59u8

proc toUsSinceBoot*(t: AbsoluteTime): uint64 {.importc: "to_us_since_boot".}
  ## convert an absolute_time_t into a number of microseconds since boot.
  ## \param t the absolute time to convert
  ## \return a number of microseconds since boot, equivalent to t
  ## \ingroup timestamp

proc updateUsSinceBoot*(t: ptr AbsoluteTime; usSinceBoot: uint64) {.importc: "update_us_since_boot".}
  ## update an absolute_time_t value to represent a given number of microseconds since boot
  ## \param t the absolute time value to update
  ## \param us_since_boot the number of microseconds since boot to represent. Note this should be representable
  ##                      as a signed 64 bit integer
  ## \ingroup timestamp

proc fromUsSinceBoot*(usSinceBoot: uint64): AbsoluteTime {.importc: "from_us_since_boot".}
  ## convert a number of microseconds since boot to an absolute_time_t
  ## \param us_since_boot number of microseconds since boot
  ## \return an absolute time equivalent to us_since_boot
  ## \ingroup timestamp

{.pop.}
