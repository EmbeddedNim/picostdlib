switch("path", "$projectDir/../src")
switch("path", getCurrentDir() & "/src")

include "../template/src/config.nims"

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/tests")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")

switch("d", "runtests")
switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")

