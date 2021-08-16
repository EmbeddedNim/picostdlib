# Package

version       = "0.2.0"
author        = "Jason"
description   = "Raspberry Pi Pico stdlib bindings/libraries"
license       = "MIT"
srcDir        = "picostdlib"

bin           = @["piconim"]
installDirs   = @["picostdlibpkg"]
installExt    = @["nim"]
# Dependencies

requires "nim >= 1.2.0"
requires "https://github.com/casey-SK/commandant"
