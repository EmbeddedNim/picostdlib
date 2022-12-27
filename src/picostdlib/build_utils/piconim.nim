import pkg/[commandant]
import std/[strformat, strutils, os, osproc, terminal, sequtils, tables]


type PicoSetupError = object of CatchableError

proc printError(msg: string) =
  echo ansiForegroundColorCode(fgRed), msg, ansiResetCode


template picoError(msg: string) =
  raise newException(PicoSetupError, msg)


proc helpMessage(): string =
  result = """Create and build Raspberry Pi Pico Nim projects.

Subcommands:
  init

Run piconim init <project-name> to create a new project directory from a
template. This will create a new folder, so make sure you are in the parent
folder. You can also provide the following options to the subcommand:

    (--sdk, -s) ->       specify the path to a locally installed pico-sdk
                         repository. ex: --sdk:/home/casey/pico-sdk
    (--overwrite, -O) -> a flag to specify overwriting an exisiting directory
                         with the <project-name> already created. Be careful
                         with this. ex: piconim myProject --overwrite will
                         replace a folder named myProject.
"""

const embeddedFiles = (proc (): Table[string, string] =
  const root = "src/picostdlib/build_utils/template"
  for item in os.walkDirRec(root, relative=true, checkDir=true):
    result[item] = staticRead("template" / item)
)()

proc validateSdkPath(sdk: string) =
  # check if the sdk option path exists and has the appropriate cmake file (very basic check...)
  if not sdk.dirExists():
    picoError fmt"could not find an existing directory with the provided --sdk argument : {sdk}"

  if not fileExists(sdk / "pico_sdk_init.cmake"):
    picoError fmt"directory provided with --sdk argument does not appear to be a valid pico-sdk library: {sdk}"


proc createProject(projectPath: string; sdk = "", override = false) =
  let name = projectPath.splitPath.tail

  echo "Select type binary or hybrid to be able to build the program"

  var nimbleProc = startProcess(
    "nimble",
    args=["init", name],
    options={poEchoCmd, poUsePath, poParentStreams}
  )
  var nimbleExit = nimbleProc.waitForExit()
  if nimbleExit != 0:
    echo fmt"nimble exited with error code: {nimbleExit}"
    echo "Will not copy over template"
  else:
    discard existsOrCreateDir(projectPath)

    for f in embeddedFiles.keys:
      echo "writing to ", projectPath / f
      let filepath = projectPath / f
      createDir(filepath.parentDir)
      writeFile(filepath, embeddedFiles[f])

    let nimbleFile = projectPath / fmt"{name}.nimble"
    # rename nim file
    moveFile(projectPath / "src/blink.nim", projectPath / fmt"src/{name}.nim")
    # moveFile(projectPath / "template.nimble", nimbleFile)

    # change all instances of template `blink` to the project name
    let cmakelists = (projectPath / "/csource/CMakeLists.txt")
    cmakelists.writeFile cmakelists.readFile.replace("blink", name)
    nimbleFile.writeFile(nimbleFile.readFile() & "requires \"picostdlib >= 0.3.2\"\n\ninclude picostdlib/build_utils/tasks\n")

  # doSetup(projectPath, name, sdk=sdk)
  #[
  nimbleProc = startProcess(
    "nimble",
    args=["configure"],
    workingDir=projectPath,
    options={poEchoCmd, poUsePath, poParentStreams}
  )
  nimbleExit = nimbleProc.waitForExit()
  if nimbleExit != 0:
    picoError fmt"nimble exited with error code: {nimbleExit}"
  ]#

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

  echo "piconim : Create Raspberry Pi Pico projects using Nim"

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
  else:
    echo helpMessage()

