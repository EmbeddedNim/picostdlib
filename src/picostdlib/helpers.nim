import std/os, std/strutils, std/macros, std/compilesettings

macro staticInclude(path: static[string]): untyped =
  newTree(nnkIncludeStmt, newLit(path))

const cmakeBinaryDir* {.strdefine.} = os.getEnv("CMAKE_BINARY_DIR").replace('\\', DirSep)
const cmakecachePath = cmakeBinaryDir / "generated" / "cmakecache.nim"

when fileExists(cmakecachePath):
  # includes PICO_SDK_PATH
  staticInclude(cmakecachePath)

const picoSdkPath* {.strdefine.} = when declared(PICO_SDK_PATH): PICO_SDK_PATH else: os.getEnv("PICO_SDK_PATH").replace('\\', DirSep)

const piconimCsourceDir* {.strdefine.} = getProjectPath().replace('\\', DirSep).parentDir() / "csource"
const picostdlibFutharkSysroot* {.strdefine.} = ""
const nimcacheDir* = querySetting(SingleValueSetting.nimcacheDir)
const futharkGenDir* = currentSourcePath.parentDir / "futharkgen"

const armSysrootInclude* = static:
  when picostdlibFutharkSysroot != "":
    picostdlibFutharkSysroot
  else:
    let sysroot = staticExec("arm-none-eabi-gcc -print-sysroot").strip().replace('\\', DirSep).normalizedPath()
    if sysroot != "" and dirExists(sysroot / "include"):
      sysroot / "include"
    elif dirExists("/usr/lib/arm-none-eabi/include"): # symlink to /usr/include/newlib on debian
      "/usr/lib/arm-none-eabi/include"
    else:
      ""

const armInstallInclude* = static:
  let searchDirsResult = staticExec("arm-none-eabi-gcc -print-search-dirs").strip()
  if searchDirsResult != "":
    let lines = searchDirsResult.split("\n")
    if lines.len >= 1:
      let firstLine = lines[0].strip().split(": ")
      if firstLine.len >= 2:
        firstLine[1].replace('\\', DirSep).normalizedPath() / "include"
      else: ""
    else: ""
  else: ""

func futharkRenameCallback*(name: string; kind: string; partof: string): string =
  result = name
  if kind in ["struct", "anon", "typedef", "enum"] and result.len > 0:
    removePrefix(result, "struct_")
    removePrefix(result, "enum_")
    if result.len > 0:
      result[0] = result[0].toUpperAscii()
