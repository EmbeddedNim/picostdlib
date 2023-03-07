import std/os, std/strutils

const picoSdkPath* {.strdefine.} = os.getEnv("PICO_SDK_PATH")
const cmakeBinaryDir* {.strdefine.} = os.getEnv("CMAKE_BINARY_DIR")
const cmakeSourceDir* {.strdefine.} = os.getEnv("CMAKE_SOURCE_DIR")

const armNoneEabiIncludePath* = staticExec("arm-none-eabi-gcc -print-sysroot") / "include"

func futharkRenameCallback*(name: string; kind: string; partof: string): string =
  result = name
  if kind in ["struct", "anon", "typedef", "enum"] and result.len > 0:
    removePrefix(result, "struct_")
    removePrefix(result, "enum_")
    if result.len > 0:
      result[0] = result[0].toUpperAscii()
