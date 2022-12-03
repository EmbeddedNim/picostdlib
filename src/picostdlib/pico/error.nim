{.push header: "pico/error.h".}

type
  PicoErrorCodes* {.pure, importc: "enum pico_error_codes".} = enum
    ## Common return codes from pico_sdk methods that return a status
    ErrorIo = -6
    ErrorInvalidArg = -5
    ErrorNotPermitted = -4
    ErrorNoData = -3
    ErrorGeneric = -2
    ErrorTimeout = -1
    ErrorNone = 0

{.pop.}
