switch("path", "$projectDir/../src")

include "../template/src/config.nims"

switch("nimcache", "build/test_pico_w/" & projectName() & "/nimcache")

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/test_pico_w")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")

switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")
