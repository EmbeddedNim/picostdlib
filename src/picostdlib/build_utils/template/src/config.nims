switch("cpu", "arm")
switch("os", "freertos")

switch("define", "release")
#switch("define", "NDEBUG") # uncomment when in release mode
# switch("opt", "size") # doesnt do anything since cmake does the compilation
switch("mm", "orc") # use "arc", "orc" or "none"
switch("deepcopy", "on")
switch("threads", "off")

switch("compileOnly", "on")
switch("nimcache", "build/" & projectName() & "/nimcache")

switch("define", "checkAbi")
switch("define", "nimMemAlignTiny")
switch("define", "useMalloc")
# switch("define", "nimAllocPagesViaMalloc")
# switch("define", "nimPage256")

# when using cpp backend
# see for similar issue: https://github.com/nim-lang/Nim/issues/17040
switch("d", "nimEmulateOverflowChecks")

# for futhark to work
switch("maxLoopIterationsVM", "1000000000")

# switch("d", "PICO_SDK_PATH:/path/to/pico-sdk")
switch("d", "CMAKE_BINARY_DIR:" & getCurrentDir() & "/build/" & projectName())
switch("d", "CMAKE_SOURCE_DIR:" & getCurrentDir() & "/csource")

## For using TCP over Wifi without futhark
# switch("d", "cyw43Gpio")
# switch("d", "cyw43Lwip")
# switch("d", "lwipIpv4")
# switch("d", "lwipTcp")
# switch("d", "lwipDns")
# switch("d", "lwipCallbackApi")
# switch("d", "lwipNetifHostname")
# switch("d", "lwipAltcp")
# # switch("d", "lwipAltcpTls")
# # switch("d", "lwipAltcpTlsMbedtls")
# # switch("d", "lwipDhcp")

switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")

