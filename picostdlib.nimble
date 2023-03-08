# Package

version       = "1.0.0"
author        = "Jason"
description   = "Raspberry Pi Pico SDK bindings"
license       = "MIT"
srcDir        = "src"

bin           = @["picostdlib/build_utils/piconim"]
installExt    = @["nim"]

# Dependencies

requires "nim >= 1.6.0"
requires "commandant >= 0.15.0"  # for piconim
requires "micros"  # for the after build hook
requires "futhark >= 0.9.1" # for bindings to lwip, cyw43_driver, btstack...

# Tests

before test:
  mkDir "build/test_pico/nimcache"
  mkDir "build/test_pico_w/nimcache"

  # truncate the json cache file
  # for CMake to detect changes later
  writeFile("build/test_pico/nimcache/test_pico.cached.json", "")
  writeFile("build/test_pico_w/nimcache/test_pico_w.cached.json", "")

  exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DOUTPUT_NAME=test_pico -S tests/pico -B build/test_pico"
  exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DOUTPUT_NAME=test_pico_w -S tests/pico_w -B build/test_pico_w"

task test, "Runs the test suite":
  exec "nimble c tests/pico/test_pico"
  exec "nimble c tests/pico_w/test_pico_w"

  cpFile("build/test_pico/nimcache/test_pico.json", "build/test_pico/nimcache/test_pico.cached.json")
  cpFile("build/test_pico_w/nimcache/test_pico_w.json", "build/test_pico_w/nimcache/test_pico_w.cached.json")

  exec "cmake --build build/test_pico -- -j4"
  exec "cmake --build build/test_pico_w -- -j4"
