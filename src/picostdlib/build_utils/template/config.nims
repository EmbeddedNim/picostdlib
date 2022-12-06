switch("cpu", "arm")
switch("os", "any")
# switch("os", "freertos")

switch("define", "release")
switch("opt", "size")
switch("mm", "arc") # use "arc", "orc" or "none"

switch("compileOnly", "on")
switch("nimcache", "build/nimcache")

switch("define", "checkAbi")
switch("define", "useMalloc")
# switch("define", "nimAllocPagesViaMalloc")
# switch("define", "nimPage256")

# when using cpp backend
# see for similar issue: https://github.com/nim-lang/Nim/issues/17040
switch("d", "nimEmulateOverflowChecks")
