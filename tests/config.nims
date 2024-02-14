switch("path", "$projectDir/../src")
switch("path", getCurrentDir() & "/src")

switch("d", "runtests")
switch("d", "futharkgen")

switch("d", "WIFI_SSID:myssid")
switch("d", "WIFI_PASSWORD:mypassword")

when not defined(mock):
  switch("os", "freertos")
  switch("define", "freertosKernelHeap:FreeRTOS-Kernel-Heap3")

  include "../template/src/config.nims"

  switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/tests")
  switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")
