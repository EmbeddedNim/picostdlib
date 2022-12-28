switch("cpu", "arm")
switch("os", "freertos")

switch("define", "release")
switch("opt", "size")
switch("mm", "orc") # use "arc", "orc" or "none"
switch("deepcopy", "on")

switch("compileOnly", "on")
switch("nimcache", "build/nimcache")

switch("define", "checkAbi")
switch("define", "useMalloc")
# switch("define", "nimAllocPagesViaMalloc")
# switch("define", "nimPage256")

# when using cpp backend
# see for similar issue: https://github.com/nim-lang/Nim/issues/17040
switch("d", "nimEmulateOverflowChecks")

## For using TCP over Wifi
# switch("d", "cyw43Lwip")
switch("d", "lwipIpv4")
switch("d", "lwipTcp")
switch("d", "lwipCallbackApi")
# switch("d", "lwipAltcp")
# switch("d", "lwipDhcp")
