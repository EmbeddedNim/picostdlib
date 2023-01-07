# Package

version       = "0.3.2"
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

requires "futhark#a73fdfc9d12412d2cc14ef61ceeed49081ebb597" # for bindings to lwip and cyw43_driver

before test:
  # truncate the json cache file
  # for CMake to detect changes later
  mkDir("build/nimcache")
  writeFile("build/nimcache/ttest.cached.json", "")
  exec("cmake -DPICO_SDK_FETCH_FROM_GIT=on -DOUTPUT_NAME=ttest -S tests -B build/tests")

task test, "Runs the test suite":
  exec "nimble c tests/ttest --verbose"
  exec "cp build/nimcache/ttest.json build/nimcache/ttest.cached.json"

after test:
  exec("cmake --build build/tests -- -j4")
