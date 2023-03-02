# Package

version       = "0.3.3"
author        = "Jason"
description   = "Raspberry Pi Pico SDK bindings"
license       = "MIT"
srcDir        = "src"

bin           = @["picostdlib/build_utils/piconim"]
installExt    = @["nim"]

# Dependencies

requires "nim >= 1.6.0"
requires "https://github.com/casey-SK/commandant >= 0.15.1"  # for piconim
requires "https://github.com/beef331/micros#e0b8e38c374c6d44ca9041d9a4cfdf323be967c1"  # for the after build hook
requires "futhark >= 0.9.0" # for bindings to lwip, cyw43_driver, btstack...

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

  exec "cp build/test_pico/nimcache/test_pico.json build/test_pico/nimcache/test_pico.cached.json"
  exec "cp build/test_pico_w/nimcache/test_pico_w.json build/test_pico_w/nimcache/test_pico_w.cached.json"

  exec "cmake --build build/test_pico -- -j4"
  exec "cmake --build build/test_pico_w -- -j4"
