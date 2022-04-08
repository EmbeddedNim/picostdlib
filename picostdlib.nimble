# Package

version       = "0.3.0"
author        = "Jason"
description   = "Raspberry Pi Pico stdlib bindings/libraries"
license       = "MIT"
srcDir        = "src"

bin           = @["piconim"]
installExt    = @["nim", "txt", "cmake"]
skipDirs = @["examples"]
installDirs = @["template"]

# Dependencies

requires "nim >= 1.2.0"
requires "https://github.com/casey-SK/commandant >= 0.15.1"
requires "https://github.com/beef331/micros"
