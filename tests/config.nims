switch("path", "$projectDir/../../src")

include "../template/src/config.nims"

if getEnv("PICO_SDK_PATH") == "":
  switch("d", "PICO_SDK_PATH:build/tests/_deps/pico_sdk-src")

switch("d", "CMAKE_SOURCE_DIR:" & projectDir())
