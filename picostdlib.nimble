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

  exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DPICO_BOARD=pico -S tests -B build/tests"
  exec "nimble c tests/pico/test_pico"
  exec "cmake --build build/tests -- -j4"

  exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DPICO_BOARD=pico_w -S tests -B build/tests"
  exec "nimble c tests/pico_w/test_pico_w"
  exec "cmake --build build/tests -- -j4"

  when not defined(windows):
    rmDir "testproject_pico"
    rmDir "testproject_pico_w"
    exec "printf '\t\r\n\r\n\r\n\r\n\r\n' | piconim init testproject_pico && cd testproject_pico && nimble configure && nimble build"
    exec "printf '\t\r\n\r\n\r\n\r\n\r\n' | piconim init -b pico_w testproject_pico_w && cd testproject_pico_w && nimble configure && nimble build"
