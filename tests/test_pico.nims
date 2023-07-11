switch("path", "$projectDir/../src")
switch("path", getCurrentDir() & "/src")

include "../template/src/config.nims"

switch("nimcache", "build/test_pico/" & projectName() & "/nimcache")

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/test_pico")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")
