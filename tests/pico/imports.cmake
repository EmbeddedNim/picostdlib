# for tests

function(link_imported_libs name)
  target_link_libraries(${name} pico_stdlib hardware_adc hardware_pwm hardware_i2c )
endFunction()
