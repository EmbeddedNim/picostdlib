if getEnv("PICO_SDK_PATH") == "":
  switch("d", "PICO_SDK_PATH:../build/tests/_deps/pico_sdk-src")

switch("d", "CMAKE_BINARY_DIR:../../build/test_pico_w")
switch("d", "CMAKE_SOURCE_DIR:../../tests/pico_w")
