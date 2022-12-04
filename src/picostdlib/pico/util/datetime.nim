import ../types

{.push header: "pico/util/datetime.h".}

proc datetimeToStr*(buf: cstring; bufSize: cuint; t: ptr DateTime) {.importc: "datetime_to_str".}
  ## ```
  ##   ! \brief  Convert a datetime_t structure to a string
  ##     \ingroup util_datetime
  ##   
  ##    \param buf character buffer to accept generated string
  ##    \param buf_size The size of the passed in buffer
  ##    \param t The datetime to be converted.
  ## ```

{.pop.}
