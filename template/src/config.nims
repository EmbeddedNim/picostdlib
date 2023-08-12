import std/os, std/macros

# switch("define", "release")
const releaseFollowsCmake = true

# used by futhark to find .h config files
switch("define", "piconimCsourceDir:" & getCurrentDir() / "csource")


#:: INTERNALS ::#

macro staticInclude(path: static[string]): untyped =
  newTree(nnkIncludeStmt, newLit(path))

const packageName = getCurrentDir().splitPath().tail
const cmakeBinaryDir {.strdefine.} = getCurrentDir() / "build" / packageName

switch("cpu", "arm")
switch("os", "freertos")
# switch("opt", "size") # doesnt do anything since cmake does the compilation
switch("mm", "orc")
switch("deepcopy", "on")
switch("threads", "off")

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

# import some cmake config
const cmakecachePath = cmakeBinaryDir / "generated" / "cmakecache.nim"
when fileExists(cmakecachePath):
  staticInclude(cmakecachePath)

  when CMAKE_BUILD_TYPE in ["Release", "MinSizeRel", "RelWithDebInfo"]:
    switch("define", "NDEBUG")
    when releaseFollowsCmake:
      switch("define", "release")

  when PICO_CYW43_SUPPORTED:
    switch("define", "picoCyw43Supported")
