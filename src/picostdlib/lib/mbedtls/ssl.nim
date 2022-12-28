{.push header: "mbedtls/ssl.h".}

type
  MbedSslContext* {.importc: "struct mbedtls_ssl_context", bycopy.} = object

proc mbedtlsSslSetHostname*(ssl: ptr MbedSslContext; hostname: cstring): cint {.importc: "mbedtls_ssl_set_hostname".}

{.pop.}
