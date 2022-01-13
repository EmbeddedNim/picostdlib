import commandant
import std/[strformat, strutils, os, osproc, httpclient, strscans, terminal, options, streams]

proc printError(msg: string) =
  echo ansiForegroundColorCode(fgRed), msg, ansiResetCode
  quit 1 # Should not be using this but short lived program


proc helpMessage(): string =
  result = "some useful message here..."

type
  LinkableLib = enum
    stdio = "pico_stdlib"
    multicore = "pico_multicore"
    adc = "hardware_adc"
    pio = "hardware_pio"
    dma = "hardware_dma"
    i2c = "hardware_i2c"
    rtc = "hardware_rtc"
    uart = "hardware_uart"
    spi = "hardware_spi"
    clock = "hardware_clocks"
    reset = "hardware_resets"
    flash = "hardware_flash"
    pwm = "hardware_pwm"
    interp = "hardware_interp"

proc getLinkedLib(fileName: string): set[LinkableLib] =
  ## Iterates over lines searching for includes adding to result
  let file = open(fileName)
  for line in file.lines:
    echo line
    if not line.startsWith("typedef"):
      var incld = ""
      if line.scanf("""#include "$+.""", incld) or line.scanf("""#include <$+.""", incld):
        let incld = incld.replace('/', '_')
        try:
          result.incl parseEnum[LinkableLib](incld)
        except: discard
    else:
      break
  close file

proc genLinkLibs() =
  ## Will create a text file in the csources containing all libs to link
  var libs: set[LinkableLib]
  for kind, path in walkDir("csource"):
    if kind == pcFile and path.endsWith(".c"):
      libs.incl getLinkedLib(path)

  const importPath = "csource" / "imports.txt"
  discard tryRemoveFile(importPath)

  let importStrm = newFileStream(importPath, fmWrite)
  for lib in libs:
    importStrm.writeLine $lib
  close importStrm


proc builder(program: string, output = "") =
  # remove previous builds
  for _, file in walkDir("csource"):
    if file.endsWith(".c"):
      removeFile(file)

  # compile the nim program to .c file
  let compileError = execCmd(fmt"nim c -c --nimcache:csource --gc:arc --cpu:arm --os:any -d:release -d:useMalloc ./src/{program}")
  if not compileError == 0:
    printError(fmt"unable to compile the provided nim program: {program}")
  genLinkLibs()
  # rename the .c file
  moveFile(("csource/" & fmt"@m{program}.c"), ("csource/" & fmt"""{program.replace(".nim")}.c"""))
  # update file timestamps
  when not defined(windows):
    let touchError = execCmd("touch csource/CMakeLists.txt")
  when defined(windows):
    let copyError = execCmd("copy /b csource/CMakeLists.txt +,,")
  # run make
  let makeError = execCmd("make -C csource/build")

proc getActiveNimVersion: string =
  let res = execProcess("nim -v")
  if not res.scanf("Nim Compiler Version $+[", result):
    result = NimVersion
  result.removeSuffix(' ')



proc validateBuildInputs(program: string, output = "") =
  if not program.endsWith(".nim"):
    printError(fmt"provided main program argument is not a nim file: {program}")
  if not fileExists(fmt"src/{program}"):
    printError(fmt"provided main program argument does not exist: {program}")
  if output != "":
    if not dirExists(output):
      printError(fmt"provided output option is not a valid directory: {output}")

proc downloadNimbase(path: string): bool =
  ## Attempts to download the nimbase if it fails returns false
  let
    nimVer = getActiveNimVersion()
    downloadPath = fmt"https://raw.githubusercontent.com/nim-lang/Nim/v{nimVer}/lib/nimbase.h"
  try:
    let client = newHttpClient()
    client.downloadFile(downloadPath, path)
    result = true
  except: echo getCurrentExceptionMsg()

proc createProject(projectPath: string; sdk = "", nimbase = "", override = false) =
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

  # get nimbase.h file from github
  if nimbase == "":
    let nimbaseError = downloadNimbase(projectPath / "csource/nimbase.h")
    if not nimbaseError:
      printError(fmt"failed to download `nimbase.h` from nim-lang repository, use --nimbase:<path> to specify a local file")
  else:
    try:
      copyFile(nimbase, (projectPath / "csource/nimbase.h"))
    except OSError:
      printError"failed to copy provided nimbase.h file"

  # move the CMakeLists.txt file, based on if an sdk was provided or not
  discard existsOrCreateDir((projectPath / "csource/build"))
  if sdk != "":
    copyFile((projectPath / "csource/CMakeLists/existingSDK_CMakeLists.txt"), (
        projectPath / "csource/CMakeLists.txt"))
    # change all instances of template `blink` to the project name
    let cmakelists = (projectPath / "/csource/CMakeLists.txt")
    cmakelists.writeFile cmakelists.readFile.replace("blink", name)   
    # run cmake from build directory
    setCurrentDir((projectPath / "/csource/build"))
    let errorCode = execCmd(fmt"cmake -DPICO_SDK_PATH={sdk} ..")
    if errorCode != 0:
      printError(fmt"while using provided sdk path, cmake exited with error code: {errorCode}")

  else:
    copyFile((projectPath / "csource/CMakeLists/downloadSDK_CMakeLists.txt"), ((
        projectPath / "csource/CMakeLists.txt")))
    # change all instances of template `blink` to the project name
    let cmakelists = (projectPath / "csource/CMakeLists.txt")
    cmakelists.writeFile cmakelists.readFile.replace("blink", name)
    # run cmake from build directory
    setCurrentDir((projectPath / "csource/build"))
    let errorCode = execCmd(fmt"cmake ..")
    if errorCode != 0:
      printError(fmt"cmake exited with error code: {errorCode}")


proc validateInitInputs(name: string, sdk, nimbase: string = "", overwrite: bool) =
  ## ensures that provided setup cli parameters will work

  # check if name is valid filename
  if not name.isValidFilename():
    printError(fmt"provided --name argument will not work as filename: {name}")

  # check if the name already has a directory with the same name
  if dirExists(joinPath(getCurrentDir(), name)) and overwrite == false:
    printError(fmt"provided project name ({name}) already has directory, use --overwrite if you wish to replace contents")

  # check if the sdk option path exists and has the appropriate cmake file (very basic check...)
  if sdk != "":
    if not sdk.dirExists():
      printError(fmt"could not find an existing directory with the provided --sdk argument : {sdk}")

    if not fileExists(fmt"{sdk}/pico_sdk_init.cmake"):
      printError(fmt"directory provided with --sdk argument does not appear to be a valid pico-sdk library: {sdk}")

  if nimbase != "":
    if not nimbase.fileExists():
      printError(fmt"could not find an existing `nimbase.h` file using provided --nimbase argument : {nimbase}")

    let (_, name, ext) = nimbase.splitFile()
    if name != "nimbase" or ext != ".h":
      printError(fmt"invalid filename or extension (expecting `nimbase.h`, recieved `{name}{ext}`")

# --- MAIN PROGRAM ---
when isMainModule:
  commandline:
    subcommand(init, "init", "i"):
      argument(name, string)
      commandant.option(sdk, string, "sdk", "s")
      commandant.option(nimbase, string, "nimbase", "n")
      flag(overwriteTemplate, "overwrite", "O")

    subcommand(build, "build", "b"):
      argument(mainProgram, string)
      commandant.option(output, string, "output", "o")

  echo "pico-nim : create raspberry pi pico projects using Nim"

  if init:
    validateInitInputs(name, sdk, nimbase, overwriteTemplate)
    createProject(name, sdk)
  elif build:
    validateBuildInputs(mainProgram, output)
    builder(mainProgram, output)
  else:
    echo helpMessage()

