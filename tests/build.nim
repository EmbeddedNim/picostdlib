
exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DPICO_BOARD=pico -S tests -B build/test_pico"
exec "nimble c tests/test_pico"
exec "cmake --build build/test_pico -- -j4"

exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DPICO_BOARD=pico_w -S tests -B build/test_pico_w"
exec "nimble c tests/test_pico_w"
exec "cmake --build build/test_pico_w -- -j4"

when not defined(windows):
  rmDir "testproject_pico"
  rmDir "testproject_pico_w"
  exec "printf '\t\r\n\r\n\r\n\r\n\r\n' | piconim init testproject_pico && cd testproject_pico && nimble configure && nimble build"
  exec "printf '\t\r\n\r\n\r\n\r\n\r\n' | piconim init -b pico_w testproject_pico_w && cd testproject_pico_w && nimble configure && nimble build"
