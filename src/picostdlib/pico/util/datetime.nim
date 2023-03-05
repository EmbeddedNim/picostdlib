import ../types
export types

{.push header: "pico/util/datetime.h".}

proc datetimeToStr*(buf: ptr char; bufSize: cuint; t: ptr Datetime) {.importc: "datetime_to_str".}
  ## Convert a datetime_t structure to a string
  ##     \ingroup util_datetime
  ##   
  ##    \param buf character buffer to accept generated string
  ##    \param buf_size The size of the passed in buffer
  ##    \param t The datetime to be converted.

{.pop.}

# Nim helpers

proc datetimeToStr*(t: var Datetime): string =
  var buffer: array[256, char]
  datetimeToStr(buffer[0].addr, buffer.len.cuint, t.addr)
  return $cast[cstring](buffer[0].addr)
