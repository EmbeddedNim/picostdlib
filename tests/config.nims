switch("path", "$projectDir/../src")
switch("path", getCurrentDir() & "/src")

include "../template/src/config.nims"

switch("define", "cyw43ArchBackend:threadsafe_background")

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/tests")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")
switch("d", "futharkgen")

switch("d", "runtests")
switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")

