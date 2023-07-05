switch("path", "$projectDir/../src")

include "../template/src/config.nims"

switch("nimcache", "build/examples/" & projectName() & "/nimcache")

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/examples")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")

switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")
