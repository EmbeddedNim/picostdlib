
import std/os, std/strutils

const PICO_SDK_PATH* {.strdefine.} = os.getEnv("PICO_SDK_PATH")
const CMAKE_BINARY_DIR* {.strdefine.} = os.getEnv("CMAKE_BINARY_DIR")

const CLANG_INCLUDE_PATH* = static:
  var sysPaths: seq[string]
  for line in staticExec("clang -x c -v -E /dev/null").split("\n"):
    if line.startsWith(" /"):
      sysPaths.add(line.substr(1))
      break
  if sysPaths.len > 0:
    sysPaths[0]
  else:
    ""

when CLANG_INCLUDE_PATH == "":
  {.warning: "clang include path not found".}

func futharkRenameCallback*(name: string; kind: string; partof: string): string =
  result = name
  if kind in ["struct", "anon", "typedef", "enum"] and result.len > 0:
    removePrefix(result, "struct_")
    removePrefix(result, "enum_")
    if result.len > 0:
      result[0] = result[0].toUpperAscii()
