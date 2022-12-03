{.push header: "pico/float.h".}

proc fix2float*(m: int32; e: cint): cfloat {.importc.}
proc ufix2float*(m: uint32; e: cint): cfloat {.importc.}
proc fix642float*(m: int64; e: cint): cfloat {.importc.}
proc ufix642float*(m: uint64; e: cint): cfloat {.importc.}

## These methods round towards -Infinity.
proc float2fix*(f: cfloat; e: cint): int32 {.importc.}
proc float2ufix*(f: cfloat; e: cint): uint32 {.importc.}
proc float2fix64*(f: cfloat; e: cint): int64 {.importc.}
proc float2ufix64*(f: cfloat; e: cint): uint64 {.importc.}
proc float2int*(f: cfloat): int32 {.importc.}
proc float2int64*(f: cfloat): int64 {.importc.}

## These methods round towards 0.
proc float2int_z*(f: cfloat): int32 {.importc.}
proc float2int64_z*(f: cfloat): int64 {.importc.}
proc exp10f*(x: cfloat): cfloat {.importc.}
proc sincosf*(x: cfloat; sinx: ptr cfloat; cosx: ptr cfloat) {.importc.}
proc powintf*(x: cfloat; y: cint): cfloat {.importc.}

{.pop.}
