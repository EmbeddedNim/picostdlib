{.push header: "pico/double.h".}

proc fix2double*(m: int32; e: cint): cdouble {.importc.}
proc ufix2double*(m: uint32; e: cint): cdouble {.importc.}
proc fix642double*(m: int64; e: cint): cdouble {.importc.}
proc ufix642double*(m: uint64; e: cint): cdouble {.importc.}

## These methods round towards -Infinity.
proc double2fix*(f: cdouble; e: cint): int32 {.importc.}
proc double2ufix*(f: cdouble; e: cint): uint32 {.importc.}
proc double2fix64*(f: cdouble; e: cint): int64 {.importc.}
proc double2ufix64*(f: cdouble; e: cint): uint64 {.importc.}
proc double2int*(f: cdouble): int32 {.importc.}
proc double2int64*(f: cdouble): int64 {.importc.}

## These methods round towards 0.
proc double2int_z*(f: cdouble): int32 {.importc.}
proc double2int64_z*(f: cdouble): int64 {.importc.}
proc exp10*(x: cdouble): cdouble {.importc.}
proc sincos*(x: cdouble; sinx: ptr cdouble; cosx: ptr cdouble) {.importc.}
proc powint*(x: cdouble; y: cint): cdouble {.importc.}

{.pop.}
