{.push header: "pico/binary_info.h".}

## TODO: Bind the binary info macros ##

type
  biProgramName* {.importc: "bi_program_name".} = proc(name: cstring) {.noconv.}

let
  BinaryInfoMarkerStart* {.importc: "BINARY_INFO_MARKER_START".}: uint32
  BinaryInfoMarkerEnd* {.importc: "BINARY_INFO_MARKER_END".}: uint32



{.pop.}
