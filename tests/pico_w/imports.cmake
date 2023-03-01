# for tests

function(link_imported_libs name)
  target_link_libraries(${name} pico_stdlib )
endFunction()
