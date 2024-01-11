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

switch("define", "picosdk")

patchFile("stdlib", "monotimes", picostdlibPath / "patches" / "monotimes")
