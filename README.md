# Raspberry Pi Pico SDK for Nim

This library provides the library and build system necessary to write
programs for RP2040 based devices (such as the Raspberry Pi Pico) in the
[Nim](https://nim-lang.org/) programming language

The libary provides wrappers for the original [Raspberry Pi Pico
SDK](https://github.com/raspberrypi/pico-sdk). The following features are
currently implemented:

* Project generator using the `piconim` tool.
* Nimble integrated build tool using tasks.
* Standard library features such as GPIO, time, ADC, PWM and many more
* Rudimentary TinyUSB support: USB device, HID and CDC (serial port) classes


## Table of Contents

[Setup](#setup)

[Building](#building)

[Examples](examples)

[Contributing](#contributing)

[License](LICENSE)


## Setup

**The following steps will install piconim and create a new project**

1. First, you will need to have the Nim compiler installed. If you don't already 
have it, consider using [choosenim](https://github.com/dom96/choosenim)

2. Since this is just a wrapper for the original 
[pico-sdk](https://github.com/raspberrypi/pico-sdk), you will need to install the C 
library [dependencies](https://github.com/raspberrypi/pico-sdk#quick-start-your-own-project) 
(Step 1 in the quick start section)

3. From the terminal, run `nimble install https://github.com/EmbeddedNim/picostdlib`.

4. Run `piconim init <project-name>` to create a new project directory from a 
template. This will create a new folder, so make sure you are in the parent folder.
When it asks for what project type, choose `>binary<` or `>hybrid<`. If you choose
`>library<` there will be nothing to build.
You can also provide the following options to the subcommand:
    - (--overwrite, -O) -> a flag to specify overwriting an exisiting directory 
    with the `<project-name>` already created. Be careful with this. 
    ex. `piconim myProject --overwrite` will replace a folder named `myProject`

5. Change directory to the new project and run `nimble configure`. This will initialize
the Pico SDK using CMake. By default it downloads the SDK from GitHub, but you can also set
the environment variable `PICO_SDK_PATH` before running `nimble configure`. This way you
can have the SDK in one place for all your projects.


## Building

Now you can work on your project. When you are ready to build the `.uf2` file 
(which will be copied to the Raspberry Pi Pico), you can use the `build` command of Nimble:

`nimble build [program]`

Where `[program]` is zero or more binaries in your `src` folder, specified in `bin`
in the project's Nimble file. (ex. `myproject`). If none are specified, it will build all of them.
The generated `.uf2` file is placed in `build/<program name>/`

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
