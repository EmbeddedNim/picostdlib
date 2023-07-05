import std/os
const packageName = getCurrentDir().splitPath().tail

switch("cpu", "arm")
switch("os", "freertos")

switch("define", "release")
# switch("define", "NDEBUG") # uncomment when in release mode
# switch("opt", "size") # doesnt do anything since cmake does the compilation
switch("mm", "orc") # use "arc", "orc" or "none"
switch("deepcopy", "on")
switch("threads", "off")

switch("compileOnly", "on")
switch("nimcache", "build/" & packageName & "/" & projectName() & "/nimcache")

switch("define", "checkAbi")
switch("define", "nimMemAlignTiny")
switch("define", "useMalloc")
# switch("define", "nimAllocPagesViaMalloc")
# switch("define", "nimPage256")

# when using cpp backend
# see for similar issue: https://github.com/nim-lang/Nim/issues/17040
switch("d", "nimEmulateOverflowChecks")

# for futhark to work
switch("maxLoopIterationsVM", "100000000")

# switch("d", "PICO_SDK_PATH:/path/to/pico-sdk")
switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/" & packageName)
switch("d", "cmakeSourceDir:" & getCurrentDir())
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/csource")

# switch("d", "WIFI_SSID:myssid")
# switch("d", "WIFI_PASSWORD:mypassword")
