# Package

version       = "0.4.0"  # Don't forget to update version in piconim.nim (if needed)
author        = "The piconim contributors"
description   = "Nim bindings for the Raspberry Pi Pico SDK"
license       = "BSD-3-Clause"
srcDir        = "src"
backend       = "c"
bin           = @["picostdlib/build_utils/piconim"]
installExt    = @["nim", "h", "c", "cmake", "txt", "md"]


# Dependencies

requires "nim >= 1.6.0"
requires "commandant >= 0.15.0"  # for piconim
requires "micros >= 0.1.8"  # for the after build hook
requires "futhark >= 0.9.2" # for bindings to lwip, cyw43_driver, btstack...

# Tests

task test, "Runs the test suite":
  include "./tests/build"

task examples, "Builds the examples":
  include "./examples/build"
