# Raspberry Pi Pico SDK for Nim

This library provides the library and build system necessary to write programs for RP2040 based devices (such as the Raspberry Pi Pico) in the [Nim](https://nim-lang.org/) programming language

The libary provides wrappers for the original [Raspberry Pi Pico SDK](https://github.com/raspberrypi/pico-sdk). Currently, standard library features such as GPIO are supported. Libraries such as TinyUSB are in development.

## Table of Contents

[Setup](##Setup)

[Building](##Building)

[Examples](examples)

[Contributing](##Contributing)

[License](LICENSE)

## Setup

**The following steps will install piconim and create a new project**

1. First, you will need to have the Nim compiler installed. If you don't already 
have it, consider using [choosenim](https://github.com/dom96/choosenim)

2. Since this is just a wrapper for the original 
[pico-sdk](https://github.com/raspberrypi/pico-sdk), you will need to install the C 
library [dependencies](https://github.com/raspberrypi/pico-sdk#quick-start-your-own-project) 
(Step 1 in the quick start section)

3. From the terminal, run `nimble install https://github.com/beef331/picostdlib`.

4. Run `piconim init <project-name>` to create a new project directory from a 
template. This will create a new folder, so make sure you are in the parent folder.
You can also provide the following options to the subcommand:
    - (--sdk, -s) -> specify the path to a locally installed `pico-sdk` repository, 
    ex.  `--sdk:/home/casey/pico-sdk`
    - (--nimbase, -n) -> similarly, you can provide the path to a locally installed 
    `nimbase.h` file. Otherwise, the program attempts to download the file from
    the nim-lang github repository. ex. `-h:/path/to/nimbase.h`
    - (--overwrite, -O) -> a flag to specify overwriting an exisiting directory 
    with the `<project-name>` already created. Be careful with this. 
    ex. `piconim myProject --overwrite` will replace a folder named `myProject`

## Building

Now you can work on your project. When you are ready to build the `.uf2` file 
(which will be copied to the Raspberry Pi Pico), you can use the `build` subcommand:

`piconim build <main-program>`

Where `<main-program>` is the main module in your `src` folder. (ex. `myProject.nim`). 
You can also specify an output directory, otherwise it will be placed in `csource/builds`

## Contributing

Please contribute.