import std/os, std/strutils, std/macros

const picoSdkPath* {.strdefine.} = os.getEnv("PICO_SDK_PATH").replace('\\', DirSep)
const cmakeBinaryDir* {.strdefine.} = os.getEnv("CMAKE_BINARY_DIR").replace('\\', DirSep)
const cmakeSourceDir* {.strdefine.} = os.getEnv("CMAKE_SOURCE_DIR").replace('\\', DirSep)
const piconimCsourceDir* {.strdefine.} = getProjectPath().parentDir() / "csource"
const picostdlibFutharkSysroot* {.strdefine.} = ""

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
