# Package

version       = "0.3.2"
author        = "Jason"
description   = "Raspberry Pi Pico SDK bindings"
license       = "MIT"
srcDir        = "src"

bin           = @["picostdlib/build_utils/piconim"]
installExt    = @["nim", "txt", "cmake"]
installDirs   = @["picostdlib/build_utils/template"]

# Dependencies

requires "nim >= 1.6.0"
requires "https://github.com/casey-SK/commandant >= 0.15.1"  # for piconim
requires "https://github.com/beef331/micros"  # for the after build hook
