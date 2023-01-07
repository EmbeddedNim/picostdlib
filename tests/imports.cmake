# for tests

function(link_imported_libs name)
  target_link_libraries(${name} hardware_i2c hardware_spi pico_stdlib pico_time )
endFunction()
