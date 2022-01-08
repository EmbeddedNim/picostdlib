import commandant
import std/[strformat, strutils, os, osproc, httpclient, strscans, terminal, sequtils]


proc printError(msg: string) =
  echo ansiForegroundColorCode(fgRed), msg, ansiResetCode
  quit 1 # Should not be using this but short lived program


proc helpMessage(): string =
  result = "some useful message here..."

proc builder(program: string, output = "") =
  let nimcache = "csource" / "build" / "nimcache"
  # remove previous builds
  for kind, file in walkDir(nimcache):
    if kind == pcFile and file.endsWith(".c"):
      removeFile(file)

  # compile the nim program to .c file
  let compileError = execCmd(fmt"nim c -c --nimcache:{nimcache} --gc:arc --cpu:arm --os:any -d:release -d:useMalloc ./src/{program}")
  if not compileError == 0:
    printError(fmt"unable to compile the provided nim program: {program}")

  # rename the .c file
  moveFile((nimcache / fmt"@m{program}.c"), (nimcache / fmt"""{program.replace(".nim")}.c"""))

  # Copy nimbase.h so it is besides the nim generated .c files
  copyFile ("csource" / "nimbase.h"), (nimcache / "nimbase.h")

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

proc validateSdkPath(sdk: string) =
  # check if the sdk option path exists and has the appropriate cmake file (very basic check...)
  if not sdk.dirExists():
    printError(fmt"could not find an existing directory with the provided --sdk argument : {sdk}")

  if not fileExists(fmt"{sdk}/pico_sdk_init.cmake"):
    printError(fmt"directory provided with --sdk argument does not appear to be a valid pico-sdk library: {sdk}")

proc findProjectName(): string =
  # Use .nimble file to find project name
  let allNimbleFiles = toSeq(walkFiles "*.nimble")
  if allNimbleFiles.len == 0:
    printError "Could not .nimble file, run \"setup\" from the root of a project created by piconim"
  elif allNimbleFiles.len > 1:
    printError "Unexpected: found multiple .nimble files"
  result = allNimbleFiles[0].splitFile[1]

proc doSetup(projectPath: string, sdk: string = "") =
  if not dirExists(projectPath):
    printError "Could not find csource directory, run \"setup\" from the root of a project created by piconim"
  if sdk != "":
    validateSdkPath sdk

  var cmakeCmd = @["cmake"]
  if sdk != "":
    cmakeCmd.add fmt"-DPICO_SDK_PATH={sdk}"
  else:
    cmakeCmd.add "-DPICO_SDK_FETCH_FROM_GIT=on"
  cmakeCmd.add ".."

  echo cmakeCmd.quoteShellCommand
  let buildDir = projectPath / "csource/build"
  discard existsOrCreateDir(buildDir)
  let cmakeResult = execCmdEx(cmakeCmd.quoteShellCommand, workingDir=buildDir)
  if cmakeResult.exitCode != 0:
    printError(fmt"cmake exited with error code: {cmakeResult.exitCode}")

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

  # change all instances of template `blink` to the project name
  let cmakelists = (projectPath / "/csource/CMakeLists.txt")
  cmakelists.writeFile cmakelists.readFile.replace("blink", name)   

  doSetup(projectPath, sdk=sdk)

proc validateInitInputs(name: string, sdk, nimbase: string = "", overwrite: bool) =
  ## ensures that provided setup cli parameters will work

  # check if name is valid filename
  if not name.isValidFilename():
    printError(fmt"provided --name argument will not work as filename: {name}")

  # check if the name already has a directory with the same name
  if dirExists(joinPath(getCurrentDir(), name)) and overwrite == false:
    printError(fmt"provided project name ({name}) already has directory, use --overwrite if you wish to replace contents")

  if sdk != "":
    validateSdkPath sdk

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
      option(sdk, string, "sdk", "s")
      option(nimbase, string, "nimbase", "n")
      flag(overwriteTemplate, "overwrite", "O")

  commandline:
    subcommand(setup, "setup"):
      option(setup_sdk, string, "sdk", "s")

    subcommand(build, "build", "b"):
      argument(mainProgram, string)
      option(output, string, "output", "o")

  echo "pico-nim : create raspberry pi pico projects using Nim"

  if init:
    validateInitInputs(name, sdk, nimbase, overwriteTemplate)
    createProject(name, sdk)
  elif build:
    validateBuildInputs(mainProgram, output)
    builder(mainProgram, output)
  elif setup:
    doSetup(".", setup_sdk)
  else:
    echo helpMessage()

