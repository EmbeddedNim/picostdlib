# Raspberry Pi Pico SDK for Nim

This library provides the library and build system necessary to write
programs for RP2040-based devices (such as the Raspberry Pi Pico) in the
[Nim](https://nim-lang.org/) programming language.

The libary provides a complete wrapper for the original [Raspberry Pi Pico
SDK](https://github.com/raspberrypi/pico-sdk). Here are some of the feature highlights:

* Project generator using the `piconim` tool
* Configure, build and upload your project using Nimble, automatically runs CMake
* Standard SDK library features such as GPIO, time, ADC, PWM and many more
* 1:1 wrapper for Pico SDK functions, with strict types for safety
* Wireless support for Pico W (Wifi, Bluetooth, TLS)

See the [examples](examples) folder for examples on how to use the SDK using Nim.


## Setup

**The following steps will install piconim and create a new project**

1. First, you will need to have the Nim compiler installed. If you don't already
have it, consider using [choosenim](https://github.com/dom96/choosenim).

2. Since this is just a wrapper for the original
[pico-sdk](https://github.com/raspberrypi/pico-sdk), you will need to install the C
library [dependencies](https://github.com/raspberrypi/pico-sdk#quick-start-your-own-project)
(Step 1 in the quick start section).

3. Some parts of this library uses [Futhark](https://github.com/PMunch/futhark) to wrap some C libraries, which depends on libclang. See its installation guide [here](https://github.com/PMunch/futhark#installation).

4. From the terminal, run `nimble install https://github.com/EmbeddedNim/picostdlib`.

5. Run `piconim init <project-name>` to create a new project directory from a
template. This will create a new folder, so make sure you are in the parent folder.
When it asks for what project type, choose `>binary<` or `>hybrid<`. If you choose
`>library<` there will be nothing to build.
You can also provide the following options to the subcommand:
    - (--sdk, -s) -> specify the path to a locally installed `pico-sdk` repository,
    ex.  `--sdk:/home/casey/pico-sdk`.
    - (--overwrite, -O) -> a flag to specify overwriting an exisiting directory 
    with the `<project-name>` already created. Be careful with this. 
    ex. `piconim myProject --overwrite` will replace a folder named `myProject`

6. Change directory to the new project and run `nimble configure`. This will initialize
the Pico SDK using CMake. If you provided a path to the SDK in the previous step, it will
use that, otherwise it will download the SDK from GitHub, but you can also set
the environment variable `PICO_SDK_PATH` before running `nimble configure`.

You are now ready to start developing and building your project.


## Building

When you are ready to build the `.uf2` file (which will be copied to the Raspberry Pi Pico),
you can use the `build` command of Nimble:

`nimble build`

The generated `.uf2` file is placed in `build/<bin name>/<bin name>.uf2`

Modify `csource/CMakeLists.txt` to suit your project's needs.

Examples:

```bash
# Initialize a new project
piconim init <project-name>

# Run the following commands from the project root.
# If you don't specify a program name, it will use all
# binaries specified in your Nimble file. You can specify multiple.

# Run CMake configure, download Pico SDK from Github (if needed)
nimble configure [program]

# Builds C/C++ files with Nim, runs CMake build/make
nimble build [program]

# Run the CMake clean target, and cleans nimcache
nimble fastclean [program]

# Clean build directories, and cleans nimcache
nimble distclean [program]

# Runs clean and then builds.
nimble buildclean [program]

# Upload using picotool (installed separately)
# Pass --build to run build task first. Add --clean to clean before building.
nimble upload [program] [--build] [--clean]

# Monitors the tty port using minicom (/dev/ttyACM0)
nimble monitor

```


## Contributing

Please contribute.
