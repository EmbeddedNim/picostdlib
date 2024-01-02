import std/os, std/macros

# switch("define", "release")
const releaseFollowsCmake = true

# used by futhark to find .h config files
when not defined(piconimCsourceDir):
  switch("define", "piconimCsourceDir:" & getCurrentDir() / "csource")

# when not defined(cyw43ArchBackend):
#   switch("define", "cyw43ArchBackend:threadsafe_background")

when not defined(freertosKernelHeap):
  # https://www.freertos.org/a00111.html
  # Default to heap 3 - wraps the standard malloc() and free() for thread safety.
  switch("define", "freertosKernelHeap:FreeRTOS-Kernel-Heap3")


#:: INTERNALS ::#

macro staticInclude(path: static[string]): untyped =
  newTree(nnkIncludeStmt, newLit(path))

const packageName = getCurrentDir().splitPath().tail
const cmakeBinaryDir {.strdefine.} = getCurrentDir() / "build" / packageName

# import cmake config
const cmakecachePath = cmakeBinaryDir / "generated" / "cmakecache.nim"
when fileExists(cmakecachePath):
  staticInclude(cmakecachePath)

  when CMAKE_BUILD_TYPE in ["Release", "MinSizeRel", "RelWithDebInfo"]:
    switch("define", "NDEBUG")
    switch("passC", "-DNDEBUG")
    when releaseFollowsCmake:
      switch("define", "release")

  when CMAKE_BUILD_TYPE == "MinSizeRel":
    switch("opt", "size") # needs to be after (define:release)

  when PICO_CYW43_SUPPORTED:
    switch("define", "picoCyw43Supported")

switch("cpu", "arm")
switch("os", "freertos")
switch("mm", "arc")
switch("deepcopy", "on")
switch("threads", "off")
# switch("hints", "off")

when false:
  # experimental, let Nim call the C compiler
  # cmake does the linking
  switch("app", "staticlib")
  switch("noMain", "off")
  switch("gcc.exe", "arm-none-eabi-gcc")
  switch("passC", "-mcpu=cortex-m0plus")
  switch("passC", "-mthumb")
  switch("out", "$nimcache/$projectName.a")
  switch("passC", "-flto")
else:
  # default is to genereate C files
  switch("compileOnly", "on")

switch("nimcache", cmakeBinaryDir / projectName() / "nimcache")

switch("define", "checkAbi")
switch("define", "nimMemAlignTiny")
switch("define", "useMalloc")
# switch("define", "nimAllocPagesViaMalloc")
# switch("define", "nimPage256")

# when using cpp backend
# see for similar issue: https://github.com/nim-lang/Nim/issues/17040
switch("define", "nimEmulateOverflowChecks")

# for futhark to work
switch("maxLoopIterationsVM", "100000000")

# redefine in case strdefine was empty
switch("define", "cmakeBinaryDir:" & cmakeBinaryDir)
