import std/[strformat, strutils, strscans, sequtils, sets, genasts, json]
import std/os except commandLineParams
import pkg/micros

type
  PicoSetupError = object of CatchableError

  LinkableLib = enum
    adc = "hardware_adc"
    base = "hardware_base"
    claim = "hardware_claim"
    clocks = "hardware_clocks"
    # divider = "hardware_divider"  ## collides with pico_divider
    dma = "hardware_dma"
    exception = "hardware_exception"
    flash = "hardware_flash"
    gpio = "pico_stdlib"
    i2c = "hardware_i2c"
    interp = "hardware_interp"
    irq = "hardware_irq"
    pio = "hardware_pio"
    pll = "hardware_pll"
    pwm = "hardware_pwm"
    reset = "hardware_resets"
    rtc = "hardware_rtc"
    spi = "hardware_spi"
    # sync = "hardware_sync"  ## collides with pico_sync
    timer = "hardware_timer"
    uart = "pico_stdlib"
    vreg = "hardware_vreg"
    watchdog = "hardware_watchdog"
    xosc = "hardware_xosc"

    multicore = "pico_multicore"

    ## pico_stdlib group
    binary_info = "pico_stdlib"
    runtime = "pico_stdlib"
    platform = "pico_stdlib"
    # printf = "pico_stdlib"  ## TODO
    stdio = "pico_stdlib"
    util = "pico_stdlib"

    sync = "pico_sync"

    time = "pico_time"

    unique_id = "pico_unique_id"

    ## pico_runtime group, part of pico_stdlib
    bit_ops = "pico_stdlib"
    divider = "pico_stdlib"
    double = "pico_stdlib"
    # int64_ops = "pico_stdlib"  ## TODO
    `float` = "pico_stdlib"
    # malloc = "pico_stdlib"  ## TODO
    # mem_ops = "pico_stdlib"  ## TODO
    # standard_link = "pico_stdlib"  ## TODO

    # util = "pico_util"  ## in group pico_stdlib already

  BackendExtension {.pure.} = enum
    c, cpp

let nimbleBackend = if backend.len > 0: backend else: "c"
let extension = $parseEnum[BackendExtension](nimbleBackend)
const nimcache = "build" / "nimcache"
const importPath = "csource" / "imports.cmake"
const cMakeIncludeTemplate = """
# This is a generated file do not modify it, 'picostdlib' makes it every build.

set(NIM_BACKEND_EXTENSION {extension})

function(link_imported_libs name)
  target_link_libraries(${{name}} {strLibs})
endFunction()

function(include_nim name)
  target_include_directories(${{name}} PUBLIC "{nimLibPath}")
endFunction()

set(NimSources
  {sources}
)
"""


template picoError(msg: string) =
  raise newException(PicoSetupError, msg)

proc getSelectedBins(): seq[string] =
  for program in bin:
    if program in commandLineParams:
      result.add program

  if result.len == 0:
    result = bin

macro parseLinkableLib(s: string) =
  ## Parses enum using the field name and field str
  let
    lLib = bindSym"LinkableLib".enumDef
    caseStmt = caseStmt(NimName s)
  var usedLabels = initHashSet[string]()
  for field in lLib.fields:
    let
      fieldName = NimNode(field)[0]
      strName = newLit $fieldName
      valStr = NimNode(field)[^1].strVal
    caseStmt.add:
      let ofBrch = ofBranch(strName, fieldName)
      if valStr notin usedLabels:
        ofBrch.addCondition NimNode(field)[^1]
      ofBrch
    usedLabels.incl valStr
  caseStmt.add:
    elseBranch():
      genAst():
        raise newException(ValueError, "Not found field")
  result = NimNode caseStmt


proc getLinkedLib(fileName: string): set[LinkableLib] =
  ## Iterates over lines searching for includes adding to result
  let file = readFile(fileName)
  for line in file.split("\n"):
    if not line.startsWith("typedef"):
      var incld = ""
      if line.scanf("""#include "$+.""", incld) or line.scanf("""#include <$+.""", incld):
        let incld = incld.replace('/', '_')
        try:
          result.incl incld.splitFile.name.parseLinkableLib()
        except: discard
    else:
      break

proc getPicoLibs(extension: string): string =
  var libs: set[LinkableLib]
  for kind, path in walkDir(nimcache):
    if kind == pcFile and path.endsWith(fmt".{extension}"):
      libs.incl getLinkedLib(path)

  for lib in libs:
    result.add $lib
    result.add " "

proc getNimLibPath: string =
  result = getCurrentCompilerExe().parentDir.parentDir / "lib"

proc genCMakeInclude(projectName: string, cfiles: openarray[string]) =
  ## Create a CMake include file in the csources containing:
  ##  - all pico-sdk libs to link
  ##  - path to current Nim compiler "lib" path, to be added to the
  ##    C compiler include path
  rmFile(importPath)

  # pico-sdk libs
  let strLibs = getPicoLibs(extension)

  # include Nim lib path for nimbase.h
  let nimLibPath = getNimLibPath()

  var sources = cfiles.join("\n  ")

  writeFile(importPath, fmt(cMakeIncludeTemplate))

task clean, "Clean task":
  rmDir(nimcache)
  let selectedBins = getSelectedBins()
  for program in bin:
    if program notin selectedBins:
      continue
    let name = program.splitPath.tail

    if dirExists("build" / program):
      echo "Cleaning ", "build" / program
      let command = "cmake --build " & "build" / program & " --target clean"
      echo command
      exec(command)

task distclean, "Distclean task":
  rmDir(nimcache)
  let selectedBins = getSelectedBins()
  for program in bin:
    if program notin selectedBins:
      continue

    if dirExists("build" / program):
      echo "Removing ", "build" / program
      rmDir("build" / program)


task configure, "Setup task":
  if not dirExists("csource"):
    picoError "Could not find csource directory!"

  # I want to put this in the beforeBuild hook,
  # but there you can't see what binaries are
  # about to be built using commandLineParams.
  rmFile(importPath)

  let selectedBins = getSelectedBins()
  for program in bin:
    if program notin selectedBins:
      continue
    let name = program.splitPath.tail

    var cmakeArgs: seq[string]
    cmakeArgs.add "-DPICO_SDK_FETCH_FROM_GIT=on"
    cmakeArgs.add "-DOUTPUT_NAME=" & name
    cmakeArgs.add "-S"
    cmakeArgs.add "csource"
    cmakeArgs.add "-B"
    cmakeArgs.add "build" / program

    let command = "cmake " & quoteShellCommand(cmakeArgs)
    echo command
    exec(command)

before build:
  # delete the nimcache json files
  # afterBuild hook will only build those that have a json file
  for program in bin:
    let name = program.splitPath.tail
    rmFile(nimcache / name & ".json")


after build:
  for program in bin:
    let name = program.splitPath.tail
    if not fileExists(nimcache / name & ".json"):
      continue

    if not dirExists("build" / program):
      picoError "Build directory " & "build" / program & " does not exist. Try run nimble configure."

    var cfiles: seq[string]

    for cfile in parseJson(readFile(nimcache / name & ".json"))["compile"]:
      cfiles.add cfile[0].getStr()

    # rename the .c file
    #let nimprogram = program.changeFileExt"nim"
    #echo "Moving ", nimcache / fmt"@m{nimprogram}.{nimExtension}", " to ", nimcache / program.changeFileExt(nimExtension)
    #mvFile(nimcache / fmt"@m{nimprogram}.{nimExtension}", nimcache / program.changeFileExt(nimExtension))
    genCMakeInclude(program, cfiles)

    # update file timestamps
    when not defined(windows):
      exec("touch csource/CMakeLists.txt")
    else:
      exec("copy /b csource/CMakeLists.txt +,,")

    # run cmake build
    var command = "cmake --build " & "build" / program & " -- -j4"
    echo command
    exec(command)

task buildclean, "Clean and build task":
  let selectedBins = getSelectedBins()
  exec("nimble clean " & quoteShellCommand(selectedBins))
  exec("nimble build " & quoteShellCommand(selectedBins))

task upload, "Upload task":
  let selectedBins = getSelectedBins()
  if selectedBins.len > 0:
    let program = selectedBins[0]
    let name = program.splitPath.tail
    if "--build" in commandLineParams and "--clean" in commandLineParams:
      exec(fmt"nimble buildclean {program}")
    elif "--build" in commandLineParams:
      exec(fmt"nimble build {program}")
    exec(fmt"picotool info build/{program}/{name}.uf2 -a")
    echo "\nUploading..."
    exec(fmt"picotool load build/{program}/{name}.uf2 -v -x -f")


task monitor, "Monitor task":
  exec("minicom -D /dev/ttyACM0")
