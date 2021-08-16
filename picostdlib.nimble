# Package

version       = "0.2.0"
author        = "Jason"
description   = "Raspberry Pi Pico stdlib bindings/libraries"
license       = "MIT"

bin           = @["piconim"]
installDirs   = @["template", "picostdlibpkg"]
installExt    = @["nim"]
# Dependencies

requires "nim >= 1.2.0"
requires "https://github.com/casey-SK/commandant"
