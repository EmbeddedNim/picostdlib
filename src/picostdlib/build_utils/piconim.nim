import pkg/[commandant]
import std/[strformat, strutils, os, osproc, terminal, sequtils, tables, macros]

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
                         repository. ex: --sdk:/home/user/pico-sdk
    (--board, -b) ->     specify the board type (pico or pico_w are accepted),
                         choosing pico_w includes a pico_w blink example
    (--overwrite, -O) -> a flag to specify overwriting an exisiting directory
                         with the <project-name> already created. Be careful
                         with this. ex: piconim myProject --overwrite will
                         replace a folder named myProject.
"""

const embeddedFiles = (proc (): OrderedTable[string, string] =
  const root = getProjectPath() / ".." / ".." / ".." / "template"
  for item in os.walkDirRec(root, relative=true, checkDir=true):
    result[item] = staticRead(root / item)
)()

proc validateSdkPath(sdk: string) =
  # check if the sdk option path exists and has the appropriate cmake file (very basic check...)
  if not sdk.dirExists():
    picoError fmt"could not find an existing directory with the provided --sdk argument : {sdk}"

  if not fileExists(sdk / "pico_sdk_init.cmake"):
    picoError fmt"directory provided with --sdk argument does not appear to be a valid pico-sdk library: {sdk}"


proc createProject(projectPath: string; sdk = ""; board: string = ""; override = false) =
  let name = projectPath.splitPath.tail

  echo "Select type binary or hybrid to be able to build the program"

  let nimbleProc = startProcess(
    "nimble",
    args=["init", name],
    options={poEchoCmd, poUsePath, poParentStreams}
  )
  let nimbleExit = nimbleProc.waitForExit()
  if nimbleExit != 0:
    echo "Nimble exited with error code: ", nimbleExit
    echo "Will not copy over template"
  else:
    discard existsOrCreateDir(projectPath)

    for f in embeddedFiles.keys:
      echo "piconim: writing file ", projectPath / f
      let filepath = projectPath / f
      createDir(filepath.parentDir)
      writeFile(filepath, embeddedFiles[f])

    if board == "pico_w":
      echo "piconim: moving ", projectPath / "src" / "picow_blink.nim", " to ", projectPath / "src" / "blink.nim"
      moveFile(projectPath / "src" / "picow_blink.nim", projectPath / "src" / "blink.nim")
    else:
      echo "piconim: removing ", projectPath / "src" / "picow_blink.nim"
      removeFile(projectPath / "src" / "picow_blink.nim")

    # rename nim file
    echo "piconim: moving ", projectPath / "src" / "blink.nim", " to ", projectPath / "src" / name & ".nim"
    moveFile(projectPath / "src" / "blink.nim", projectPath / "src" / name & ".nim")

    # add picostdlib tasks to nimble file
    let nimbleFile = projectPath / name & ".nimble"
    echo "piconim: updating file ", nimbleFile
    nimbleFile.writeFile(nimbleFile.readFile() & "requires \"picostdlib >= 0.4.0\"\n\ninclude picostdlib/build_utils/tasks\n")

    # replace blink name with project name
    # set SDK path if provided
    let cmakelistsPath = projectPath / "CMakeLists.txt"
    var cmakelistsContent = cmakelistsPath.readFile()
    cmakelistsContent = cmakelistsContent.replace("blink", name)
    if sdk != "":
      cmakelistsContent = cmakelistsContent.replace("# set(PICO_SDK_PATH ENV{PICO_SDK_PATH})", "set(PICO_SDK_PATH \"" & sdk & "\") # Set by piconim")
      let configPath = projectPath / "src" / "config.nims"
      var configContent = configPath.readFile()
      configContent = configContent.replace("# switch(\"d\", \"PICO_SDK_PATH:/path/to/pico-sdk\")", "switch(\"d\", \"" & "PICO_SDK_PATH:" & sdk & "\") # Set by piconim")
      echo "piconim: updating file ", configContent
      configPath.writeFile(configContent)
    cmakelistsContent = cmakelistsContent.replace("set(PICO_BOARD pico)", "set(PICO_BOARD " & board & ") # Set by piconim")
    if board == "pico_w":
      cmakelistsContent = cmakelistsContent.replace("# pico_cyw43_arch_lwip_threadsafe_background pico_lwip_mbedtls pico_mbedtls", "pico_cyw43_arch_lwip_threadsafe_background pico_lwip_mbedtls pico_mbedtls")
    echo "piconim: updating file ", cmakelistsPath
    cmakelistsPath.writeFile(cmakelistsContent)

    echo "Project created!"
    echo &"Type `cd {name}` and then `nimble configure` to configure CMake"
    echo "Then run `nimble build` to compile the project"

proc validateInitInputs(name: string, sdk: string = "", board: string = "", overwrite: bool) =
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
      commandant.option(board, string, "board", "b", "pico")
      commandant.option(sdk, string, "sdk", "s")
      flag(overwriteTemplate, "overwrite", "O")

  echo "piconim: Create Raspberry Pi Pico projects using Nim"

  if init:
    validateInitInputs(name, sdk, board, overwriteTemplate)
    let dirDidExist = dirExists(name)
    try:
      createProject(name, sdk, board)
    except PicoSetupError as e:
      printError(e.msg)
      if not dirDidExist:
        try:
         removeDir(name) # We failed remove file
        except IOError:
          discard
  else:
    echo helpMessage()
