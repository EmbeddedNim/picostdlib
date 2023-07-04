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

    rand = "pico_rand"

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
const cMakeIncludeTemplate = """
# This is a generated file do not modify it, 'picostdlib' makes it every build.

function(link_imported_libs name)
  target_link_libraries(${{name}} {strLibs})
endFunction()
"""

proc importPath(program: string): string = "build" / projectName() / program / "imports.cmake"
proc nimcache(program: string): string = "build" / projectName() / program / "nimcache"

proc namedProgram(program: string): string =
  if namedBin.hasKey(program):
    namedBin[program]
  else:
    program

template picoError(msg: string) =
  raise newException(PicoSetupError, msg)

iterator getPrograms(): string =
  if namedBin.len > 0:
    for key in namedBin.keys:
      yield key
  else:
    for program in bin:
      yield program

proc getSelectedBins(): seq[string] =
  if namedBin.len > 0:
    for key in namedBin.keys:
      if key in commandLineParams:
        result.add key
    if result.len == 0:
      for key in namedBin.keys:
        result.add key
        break
  else:
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

proc getPicoLibs(program: string, extension: string): string =
  var libs: set[LinkableLib]
  for kind, path in walkDir(nimcache(program)):
    if kind == pcFile and path.endsWith(fmt".{extension}"):
      libs.incl getLinkedLib(path)

  for lib in libs:
    result.add $lib
    result.add " "

proc genCMakeInclude(program: string) =
  ## Create a CMake include file in the csources containing:
  ##  - all pico-sdk libs to link
  ##  - path to current Nim compiler "lib" path, to be added to the
  ##    C compiler include path

  let buildImportPath = importPath(program)

  # rmFile(buildImportPath)

  # pico-sdk libs
  let strLibs = getPicoLibs(program, extension)

  # only update file if contents change
  # to prevent CMake from reconfiguring
  if fileExists(buildImportPath):
    let oldTemplate = readFile(buildImportPath)
    let newTemplate = fmt(cMakeIncludeTemplate)
    if oldTemplate != newTemplate:
      writeFile(buildImportPath, newTemplate)
  else:
    mkDir(buildImportPath.parentDir())
    writeFile(buildImportPath, fmt(cMakeIncludeTemplate))

task fastclean, "Clean task":
  let selectedBins = getSelectedBins()
  for program in getPrograms():
    if program notin selectedBins:
      continue

    rmDir(nimcache(program))

    if dirExists("build" / program):
      echo "Cleaning ", "build" / program
      let command = "cmake --build " & "build" / program & " --target clean"
      echo command
      exec(command)

task distclean, "Distclean task":
  let selectedBins = getSelectedBins()
  for program in getPrograms():
    if program notin selectedBins:
      continue

    if dirExists("build" / program):
      echo "Removing ", "build" / program
      rmDir("build" / program)


task configure, "Setup task":

  # I want to put this in the beforeBuild hook,
  # but there you can't see what binaries are
  # about to be built using commandLineParams.

  let selectedBins = getSelectedBins()
  for program in getPrograms():
    if program notin selectedBins:
      continue

    let buildImportPath = importPath(program)
    rmFile(buildImportPath)

    var cmakeArgs: seq[string]
    cmakeArgs.add "-DPICO_SDK_FETCH_FROM_GIT=on"
    cmakeArgs.add "-DOUTPUT_NAME=" & namedProgram(program)
    cmakeArgs.add "-S"
    cmakeArgs.add "."
    cmakeArgs.add "-B"
    cmakeArgs.add "build" / program

    let command = "cmake " & quoteShellCommand(cmakeArgs)
    echo command
    exec(command)

before build:
  # delete the nimcache json files
  # afterBuild hook will only build those that have a json file
  for program in getPrograms():
    let jsonFile = nimcache(program) / namedProgram(program) & ".json"
    if fileExists(jsonFile):
      rmFile(jsonFile)


after build:
  var elfs: seq[string]
  for program in getPrograms():
    let jsonFile = nimcache(program) / namedProgram(program) & ".json"
    if not fileExists(jsonFile):
      continue
    let jsonFileCached = jsonFile.changeFileExt(".cached.json")

    if fileExists(jsonFileCached):
      let oldJsonFile = readFile(jsonFileCached)
      let newJsonFile = readFile(jsonFile)
      if oldJsonFile != newJsonFile:
        # only copy the json file if contents change
        cpFile(jsonFile, jsonFileCached)
      else:
        # copy and preserve timestamp to prevent CMake from reconfiguring
        when defined(posix):
          exec("cp -p " & quoteShell(jsonFileCached) & " " & quoteShell(jsonFile))
    else:
      cpFile(jsonFile, jsonFileCached)

    if not dirExists("build" / program):
      picoError "Build directory " & "build" / program & " does not exist. Try run nimble configure."

    genCMakeInclude(namedProgram(program))

    # run cmake build
    var command = "cmake --build " & "build" / program & " -- -j4"
    echo command
    exec(command)
    elfs.add("build" / program / program & ".elf")

  try:
    exec("arm-none-eabi-size -G " & quoteShellCommand(elfs))
  except OSError as e: echo e.msg

task buildclean, "Clean and build task":
  let selectedBins = getSelectedBins()
  exec("nimble fastclean " & quoteShellCommand(selectedBins))
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
