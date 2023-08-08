switch("path", "$projectDir/..")

switch("d", "futharkgen")
switch("d", "useFuthark")
switch("d", "futharkRebuild")
switch("d", "opirRebuild")

include "../../template/src/config.nims"

switch("d", "cmakeBinaryDir:" & getCurrentDir() & "/build/tests")
switch("d", "piconimCsourceDir:" & getCurrentDir() & "/template/csource")
