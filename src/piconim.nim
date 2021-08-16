import commandant
import strformat
import strutils
import os
import osproc

proc helpMessage(): string =
  result = "some useful message here..."

proc builder(program: string, output = "") = 
  # remove previous builds
  for _ , file in walkDir("csource"):
    if file.endsWith(".c"):
      removeFile(file)
  
  # compile the nim program to .c file
  let compileError = execCmd(fmt"nim c -c --nimcache:csource --gc:arc --cpu:arm --os:any -d:release -d:useMalloc ./src/{program}")
  if not compileError == 0:
    raise newException(OSError, fmt"unable to compile the provided nim program: {program}")
  # rename the .c file
  moveFile(("csource/" & fmt"@m{program}.c"), ("csource/" & fmt"""{program.replace(".nim")}.c"""))
  # update file timestamps
  when not defined(windows):
    let touchError = execCmd("touch csource/CMakeLists.txt")
  when defined(windows):
    let copyError = execCmd("copy /b csource/CMakeLists.txt +,,")
  # run make
  let makeError = execCmd("make -C csource/build")


proc validateBuildInputs(program: string, output = "") = 
  if not program.endsWith(".nim"):
    raise newException(ValueError, fmt"provided main program argument is not a nim file: {program}")
  if not fileExists(fmt"src/{program}"):
    raise newException(ValueError, fmt"provided main program argument does not exist: {program}")
  if output != "":
    if not dirExists(output):
      raise newException(ValueError, fmt"provided output option is not a valid directory: {output}")
  
proc createProject(name: string; sdk = "", nimbase = "", override = false) = 
  # copy the template over to the current directory
  let sourcePath = joinPath(getAppDir(), "template")
  let newProjectFolder = joinPath(getCurrentDir(), name)
  copyDir(sourcePath, newProjectFolder)
  # rename nim file
  moveFile((newProjectFolder & "/src/blink.nim"), (newProjectFolder & fmt"/src/{name}.nim"))

  # get nimbase.h file from github
  if nimbase == "":
    let nimbaseError: int = execCmd(fmt"curl --silent --output {newProjectFolder}/csource/nimbase.h https://raw.githubusercontent.com/nim-lang/Nim/v{NimVersion}/lib/nimbase.h")
    if nimbaseError != 0:
      raise newException(OSError, fmt"failed to download `nimbase.h` from nim-lang repository, use --nimbase:<path> to specify a local file")
  else:
    try:
      copyFile(nimbase, (newProjectFolder & "/csource/nimbase.h"))
    except OSError:
      raise newException(OSError, fmt"failed to copy provided nimbase.h file")

  # move the CMakeLists.txt file, based on if an sdk was provided or not
  discard existsOrCreateDir((newProjectFolder & "/csource/build"))
  if sdk != "":
    copyFile((newProjectFolder & "/csource/CMakeLists/existingSDK_CMakeLists.txt"), (newProjectFolder & "/csource/CMakeLists.txt"))
    setCurrentDir((newProjectFolder & "/csource/build"))
    # change all instances of template `blink` to the project name
    let cmakelists = (newProjectFolder & "/csource/CMakeLists.txt")
    cmakelists.writeFile cmakelists.readFile.replace("blink", name)
    let errorCode = execCmd(fmt"cmake -DPICO_SDK_PATH={sdk} ..")
    if errorCode != 0:
      raise newException(OSError, fmt"while using provided sdk path, cmake exited with error code: {errorCode}")
        
  else:
    copyFile((newProjectFolder & "/csource/CMakeLists/downloadSDK_CMakeLists.txt"), ((newProjectFolder & "/csource/CMakeLists.txt")))
    setCurrentDir((newProjectFolder & "/csource/build"))
    # change all instances of template `blink` to the project name
    let cmakelists = (newProjectFolder & "/csource/CMakeLists.txt")
    cmakelists.writeFile cmakelists.readFile.replace("blink", name)
    let errorCode = execCmd(fmt"cmake ..")
    if errorCode != 0:
      raise newException(OSError, fmt"cmake exited with error code: {errorCode}")


proc validateInitInputs(name: string, sdk, nimbase: string = "", overwrite: bool) =
  ## ensures that provided setup cli parameters will work

  # check if name is valid filename
  if not name.isValidFilename(): 
    raise newException(ValueError, fmt"provided --name argument will not work as filename: {name}")
  
  # check if the name already has a directory with the same name
  if dirExists(joinPath(getCurrentDir(), name)) and overwrite == false: 
    raise newException(ValueError, fmt"provided project name ({name}) already has directory, use --overwrite if you wish to replace contents")

  # check if the sdk option path exists and has the appropriate cmake file (very basic check...)
  if sdk != "":
    if not sdk.dirExists():
      raise newException(ValueError, fmt"could not find an existing directory with the provided --sdk argument : {sdk}")

    if not fileExists(fmt"{sdk}/pico_sdk_init.cmake"):
      raise newException(ValueError, fmt"directory provided with --sdk argument does not appear to be a valid pico-sdk library: {sdk}")

  if nimbase != "":
    if not nimbase.fileExists():
      raise newException(ValueError, fmt"could not find an existing `nimbase.h` file using provided --nimbase argument : {nimbase}")

    let ( _ , name, ext) = nimbase.splitFile()
    if name != "nimbase" or ext != ".h":
      raise newException(ValueError, fmt"invalid filename or extension (expecting `nimbase.h`, recieved `{name}{ext}`")

    



# --- MAIN PROGRAM ---

commandline:
  subcommand(init, "init", "i"):
    argument(name, string)
    option(sdk, string, "sdk", "s")
    option(nimbase, string, "nimbase", "h")
    flag(overwriteTemplate, "overwrite", "O")
  
  subcommand(build, "build", "b"):
    argument(mainProgram, string)
    option(output, string, "output", "o")

echo "pico-nim : create raspberry pi pico projects using Nim"

if init:
  validateInitInputs(name, sdk, nimbase, overwriteTemplate)
  createProject(name,sdk)
elif build:
  validateBuildInputs(mainProgram, output)
  builder(mainProgram, output)
else:
  echo helpMessage()

