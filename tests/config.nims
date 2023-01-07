switch("path", "$projectDir/../src")

include "../src/picostdlib/build_utils/template/config.nims"

if getEnv("PICO_SDK_PATH") == "":
  switch("d", "PICO_SDK_PATH:../build/tests/_deps/pico_sdk-src")
switch("d", "CMAKE_BINARY_DIR:../build/tests")
