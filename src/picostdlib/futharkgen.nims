switch("d", "futharkgen")
switch("d", "futharkRebuild")
switch("path", "$projectDir/..")

include "../../template/src/config.nims"

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/tests")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")
