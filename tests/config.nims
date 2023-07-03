switch("path", "$projectDir/../../src")

include "../template/src/config.nims"

if getEnv("PICO_SDK_PATH") == "":
  switch("d", "PICO_SDK_PATH:build/tests/_deps/pico_sdk-src")

switch("d", "piconimCsourceDir:" & projectDir() & "/../../template/csource")

switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")
