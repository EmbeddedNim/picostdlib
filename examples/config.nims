switch("path", "$projectDir/../src")
switch("path", getCurrentDir() & "/src")

include "../template/src/config.nims"

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/examples")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")
switch("d", "futharkgen")

when fileExists("secret.nims"):
  import "../secret.nims"
  when declared(WIFI_SSID):
    switch("d", "WIFI_SSID:" & WIFI_SSID)
  when declared(WIFI_PASSWORD):
    switch("d", "WIFI_PASSWORD:" & WIFI_PASSWORD)
