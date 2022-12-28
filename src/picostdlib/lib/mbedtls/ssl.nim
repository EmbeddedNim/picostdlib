
import ../../hardware/structs/rosc
import ../../pico/platform

# converted to Nim from https://github.com/raspberrypi/pico-sdk/pull/1151

var pollByte: uint8

# Function to feed mbedtls entropy.
proc mbedtlsHardwarePoll*(data: pointer; output: ptr UncheckedArray[uint8]; len: csize_t; olen: ptr csize_t): cint {.exportc: "mbedtls_hardware_poll", noconv.} =
  ## Code borrowed from pico_lwip_random_byte(), which is static, so we cannot call it directly

  for p in 0..<len:
    for i in 0..<32:
      ## picked a fairly arbitrary polynomial of 0x35u - this doesn't have to be crazily uniform.
      pollByte = (((pollByte shl 1) or roscHw.randombit) xor (if (pollByte and 0x80'u).bool: 0x35'u else: 0'u)).uint8
      ## delay a little because the random bit is a little slow
      busyWaitAtLeastCycles(30)

    output[p] = pollByte;

  olen[] = len
  return 0


{.push header: "mbedtls/ssl.h".}

type
  MbedSslContext* {.importc: "struct mbedtls_ssl_context", bycopy.} = object

proc mbedtlsSslSetHostname*(ssl: ptr MbedSslContext; hostname: cstring): cint {.importc: "mbedtls_ssl_set_hostname".}

{.pop.}
