# Package

version       = "0.4.0"  # Don't forget to update version in piconim.nim (if needed)
author        = "The piconim contributors"
description   = "Raspberry Pi Pico SDK bindings"
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

before test:
  mkDir "build/test_pico/nimcache"
  mkDir "build/test_pico_w/nimcache"

  rmDir "testproject_pico"
  rmDir "testproject_pico_w"

  # truncate the json cache file
  # for CMake to detect changes later
  writeFile("build/test_pico/nimcache/test_pico.cached.json", "")
  writeFile("build/test_pico_w/nimcache/test_pico_w.cached.json", "")

  exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DOUTPUT_NAME=test_pico -S tests/pico -B build/test_pico"
  exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DOUTPUT_NAME=test_pico_w -S tests/pico_w -B build/test_pico_w"


task test, "Runs the test suite":
  exec "nimble c tests/pico/test_pico"
  exec "nimble c tests/pico_w/test_pico_w"

  when not defined(windows):
    exec "cat tests/init.txt | piconim init testproject_pico && cd testproject_pico && nimble configure && nimble build"
    exec "cat tests/init.txt | piconim init -b pico_w testproject_pico_w && cd testproject_pico_w && nimble configure && nimble build"

after test:
  cpFile("build/test_pico/nimcache/test_pico.json", "build/test_pico/nimcache/test_pico.cached.json")
  cpFile("build/test_pico_w/nimcache/test_pico_w.json", "build/test_pico_w/nimcache/test_pico_w.cached.json")

  exec "cmake --build build/test_pico -- -j4"
  exec "cmake --build build/test_pico_w -- -j4"
