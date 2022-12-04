import pkg/[commandant, micros]
import std/[strformat, strutils, os, osproc, strscans, terminal, sequtils, sets, genasts]


type PicoSetupError = object of CatchableError

proc printError(msg: string) =
  echo ansiForegroundColorCode(fgRed), msg, ansiResetCode


template picoError(msg: string) =
  raise newException(PicoSetupError, msg)


proc helpMessage(): string =
  result = """Create and build Raspberry Pi Pico Nim projects.

Subcommands:
  init
  setup
  build

Run piconim init <project-name> to create a new project directory from a
template. This will create a new folder, so make sure you are in the parent
folder. You can also provide the following options to the subcommand:

    (--sdk, -s) ->       specify the path to a locally installed pico-sdk
                         repository. ex: --sdk:/home/casey/pico-sdk
    (--overwrite, -O) -> a flag to specify overwriting an exisiting directory
                         with the <project-name> already created. Be careful
                         with this. ex: piconim myProject --overwrite will
                         replace a folder named myProject.

Run piconim setup <project-name> to create the "csource/build" directory. This
is required before building if the "csource/build" does not yet exist (for
example after a fresh clone or git clean of an existing project.) The following
options are available:

    (--sdk, -s) -> specify the path to a locally installed pico-sdk repository.
                   ex: --sdk:/home/casey/pico-sdk

Run piconim build <main-program> to compile the project, the <main-program>.uf2
file will be located in `csource/build`
"""

type
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
  let file = open(fileName)
  defer: file.close
  for line in file.lines:
    if not line.startsWith("typedef"):
      var incld = ""
      if line.scanf("""#include "$+.""", incld) or line.scanf("""#include <$+.""", incld):
        let incld = incld.replace('/', '_')
        try:
          result.incl incld.splitFile.name.parseLinkableLib()
        except: discard
    else:
      break

proc getNimLibPath: string =
  let (nimOutput, nimExitCode) = execCmdEx(
    "nim --verbosity:0 --eval:\"import std/os; echo getCurrentCompilerExe()\"",
    options={poUsePath}
  )

  if nimExitCode != 0:
    echo nimOutput
    picoError fmt"Error while trying to locate nim executable (exit code {nimExitCode})"

  result = nimOutput.parentDir.parentDir / "lib"

const cMakeIncludeTemplate = """
# This is a generated file do not modify it, 'piconim' makes it every run.
function(link_imported_libs name)
  target_link_libraries(${{name}} {strLibs})
endFunction()

target_include_directories(${{OUTPUT_NAME}} PUBLIC "{nimLibPath}")
"""

const nimcache = "csource" / "build" / "nimcache"

proc getPicoLibs: string =
  var libs: set[LinkableLib]
  for kind, path in walkDir(nimcache):
    if kind == pcFile and path.endsWith(".c"):
      libs.incl getLinkedLib(path)

  for lib in libs:
    result.add $lib
    result.add " "

proc genCMakeInclude(projectName: string) =
  ## Create a CMake include file in the csources containing:
  ##  - all pico-sdk libs to link
  ##  - path to current Nim compiler "lib" path, to be added to the
  ##    C compiler include path
  const importPath = "csource" / "imports.cmake"
  discard tryRemoveFile(importPath)

  # pico-sdk libs
  let strLibs = getPicoLibs()

  # include Nim lib path for nimbase.h
  let nimLibPath = getNimLibPath()

  writeFile(importPath, fmt(cMakeIncludeTemplate))

proc builder(program: string) =
  # remove previous builds
  for kind, file in walkDir(nimcache):
    if kind == pcFile and file.endsWith(".c"):
      removeFile(file)

  # compile the nim program to .c file
  let nimcmd = fmt"nimble c --compileOnly:on --nimcache:{nimcache} ./src/{program}"
  echo fmt"Nim command line: {nimcmd}"
  let compileError = execCmd(nimcmd)
  if not compileError == 0:
    picoError(fmt"unable to compile the provided nim program: {program}")

  # rename the .c file
  let nimprogram = program.changeFileExt"nim"
  moveFile(nimcache / fmt"@m{nimprogram}.c", nimcache / program.changeFileExt("c"))
  genCMakeInclude(program)
  # update file timestamps
  when not defined(windows):
    discard execCmd("touch csource/CMakeLists.txt")
  else:
    discard execCmd("copy /b csource/CMakeLists.txt +,,")

  # run cmake build
  discard execCmd("cmake --build csource/build")

proc validateSdkPath(sdk: string) =
  # check if the sdk option path exists and has the appropriate cmake file (very basic check...)
  if not sdk.dirExists():
    picoError fmt"could not find an existing directory with the provided --sdk argument : {sdk}"

  if not fileExists(sdk / "pico_sdk_init.cmake"):
    picoError fmt"directory provided with --sdk argument does not appear to be a valid pico-sdk library: {sdk}"

proc doSetup(projectPath: string, program: string, sdk: string = "") =
  if not dirExists(projectPath / "csource"):
    picoError "Could not find csource directory, run \"setup\" from the root of a project created by piconim"
  if sdk != "":
    validateSdkPath sdk

  var cmakeArgs: seq[string]
  if sdk != "":
    cmakeArgs.add fmt"-DPICO_SDK_PATH={sdk}"
  else:
    cmakeArgs.add "-DPICO_SDK_FETCH_FROM_GIT=on"
  cmakeArgs.add "-DOUTPUT_NAME=" & program
  cmakeArgs.add "-S"
  cmakeArgs.add "csource"
  cmakeArgs.add "-B"
  cmakeArgs.add "csource/build"

  echo "Project path: ", projectPath

  let cmakeProc = startProcess(
    "cmake",
    args=cmakeArgs,
    workingDir=projectPath,
    options={poEchoCmd, poUsePath, poParentStreams}
  )
  let cmakeExit = cmakeProc.waitForExit()
  if cmakeExit != 0:
    picoError fmt"cmake exited with error code: {cmakeExit}"

proc createProject(projectPath: string; sdk = "", override = false) =
  # copy the template over to the current directory
  let
    sourcePath = joinPath(getAppDir(), "template")
    name = projectPath.splitPath.tail
  discard existsOrCreateDir(projectPath)
  copyDir(sourcePath, projectPath)
  # rename nim file
  moveFile(projectPath / "src/blink.nim", projectPath / fmt"src/{name}.nim")
  moveFile(projectPath / "template.nimble", projectPath /
      fmt"{name}.nimble")

  # change all instances of template `blink` to the project name
  let cmakelists = (projectPath / "/csource/CMakeLists.txt")
  cmakelists.writeFile cmakelists.readFile.replace("blink", name)

  doSetup(projectPath, name, sdk=sdk)

proc validateInitInputs(name: string, sdk: string = "", overwrite: bool) =
  ## ensures that provided setup cli parameters will work

  # check if name is valid filename
  if not name.isValidFilename():
    picoError fmt"provided --name argument will not work as filename: {name}"

  # check if the name already has a directory with the same name
  if dirExists(joinPath(getCurrentDir(), name)) and overwrite == false:
    picoError fmt"provided project name ({name}) already has directory, use --overwrite if you wish to replace contents"

  if sdk != "":
    validateSdkPath sdk


# --- MAIN PROGRAM ---
when isMainModule:
  commandline:
    subcommand(init, "init", "i"):
      argument(name, string)
      commandant.option(sdk, string, "sdk", "s")
      flag(overwriteTemplate, "overwrite", "O")

  commandline:
    subcommand(setup, "setup"):
      argument(programSetup, string)
      commandant.option(setup_sdk, string, "sdk", "s")

    subcommand(build, "build", "b"):
      argument(programBuild, string)
      # commandant.option(output, string, "output", "o")

  echo "pico-nim : create raspberry pi pico projects using Nim"

  if init:
    validateInitInputs(name, sdk, overwriteTemplate)
    let dirDidExist = dirExists(name)
    try:
      createProject(name, sdk)
    except PicoSetupError as e:
      printError(e.msg)
      if not dirDidExist:
        try:
         removeDir(name) # We failed remove file
        except IOError:
          discard
  elif build:
    builder(programBuild)
  elif setup:
    doSetup(".", programSetup, setup_sdk)
  else:
    echo helpMessage()

