import pkg/[commandant]
import std/[strformat, strutils, os, osproc, terminal, sequtils, tables, macros, json]
import ./common

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
                         repository. ex: --sdk:/home/user/pico-sdk
    (--board, -b) ->     specify the board type (pico or pico_w are accepted),
                         choosing pico_w includes a pico_w blink example
    (--overwrite, -O) -> a flag to specify overwriting an exisiting directory
                         with the <project-name> already created. Be careful
                         with this. ex: piconim myProject --overwrite will
                         replace a folder named myProject.

Run piconim setup to create the `build/<project>/` directory. This
is required before building if the `build/<project>/` does not yet exist (for
example after a fresh clone or git clean of an existing project.) The following
options are available:

    (--project, -p) ->   specify build project name. By default it will
                         use the nimble package's name as project name
    (--source, -S) -->   specify the source directory containing the
                         CMakeLists.txt file you wish to use. By default it
                         is set to the current directory.
    (--sdk, -s) ->       specify the path to a locally installed pico-sdk
                         repository. This is only used for the setup.
    (--board, -b) ->     specify the board type. This is only used for the setup.
    (--fresh, -f) ->     Perform a fresh configuration of the build tree.

Run piconim build <program> to compile the project, the <program>.uf2
file will be located in `build/<project>/`

    (--project, -p) ->   specify build project name. By default it will
                         use the nimble package's name as project name
    (--target, -t) ->    specify the cmake target associated with this binary.
                         By default it will be the program's basename.
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

proc getProjectInfo(): JsonNode =
  return execProcess("nimble", args = ["dump", "--json"], options = {poStdErrToStdOut, poUsePath}).parseJson()

proc doSetup(projectIn = ""; sourceDirIn = "."; boardIn = ""; sdk = ""; fresh = false) =
  let projectInfo = getProjectInfo()
  let project = if projectIn != "": projectIn else: projectInfo["name"].str
  buildDir = "build" / project

  echo "Setting up " & buildDir

  var cmakeArgs: seq[string]
  cmakeArgs.add "-DPICO_SDK_FETCH_FROM_GIT=on"
  if sdk != "":
    cmakeArgs.add "-DPICO_SDK_PATH=" & sdk
  if boardIn != "":
    cmakeArgs.add "-DPICO_BOARD=" & boardIn
  cmakeArgs.add "-S"
  cmakeArgs.add sourceDirIn
  cmakeArgs.add "-B"
  cmakeArgs.add buildDir
  if fresh:
    cmakeArgs.add "--fresh"

  let cmakecmd = "cmake " & quoteShellCommand(cmakeArgs)
  echo ">> " & cmakecmd
  discard execCmd(cmakecmd)

proc doBuild(mainProgram: string; projectIn = ""; targetIn = "") =
  let projectInfo = getProjectInfo()
  let project = if projectIn != "": projectIn else: projectInfo["name"].str
  buildDir = "build" / project

  let program = mainProgram.split(DirSep)[^1]
  let target = if targetIn != "": targetIn else: program
  let backend = if projectInfo["backend"].str != "": projectInfo["backend"].str else: "c"

  if not fileExists(buildDir / "CMakeCache.txt"):
    doSetup(project)

  echo "Building in " & buildDir
  let jsonFile = nimcache(program) / program & ".json"
  if fileExists(jsonFile):
    removeFile(jsonFile)

  # compile the nim program to .c files
  let nimcmd = "nim " & quoteShellCommand([backend, "-c", "--hints:off", mainProgram])
  echo ">> " & nimcmd
  if execCmd(nimcmd) != 0:
    picoError(fmt"unable to compile the provided nim program: {mainProgram}")

  genCMakeInclude(program, backend)
  updateJsonCache(jsonFile)

  # run cmake build
  var args = @["--build", buildDir, "--target", target, "--"]
  if countProcessors() > 1:
    args.add("-j" & $countProcessors())
  let cmakecmd = "cmake " & quoteShellCommand(args)
  echo ">> " & cmakecmd
  discard execCmd(cmakecmd)

  # size statistics for compiled binary
  let elf = buildDir / program & ".elf"
  if fileExists(elf):
    discard execCmd("arm-none-eabi-size -G " & quoteShell(elf))


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
    subcommand(setup, "setup"):
      commandant.option(projectInSetup, string, "project", "p")
      commandant.option(sourceDirIn, string, "source", "S", ".")
      commandant.option(setupSdk, string, "sdk", "s")
      commandant.option(boardIn, string, "board", "b")
      flag(setupFresh, "fresh", "f")
    subcommand(build, "build", "b"):
      argument(mainProgram, string)
      commandant.option(projectInBuild, string, "project", "p")
      commandant.option(targetIn, string, "target", "t")

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
  elif setup:
    doSetup(projectInSetup, sourceDirIn, boardIn, setupSdk, setupFresh)
  elif build:
    doBuild(mainProgram, projectInBuild, targetIn)
  else:
    echo helpMessage()
