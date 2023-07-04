# for examples

function(link_imported_libs name)
  target_link_libraries(${name} pico_stdlib hardware_adc hardware_pwm hardware_i2c hardware_rtc pico_multicore hardware_dma hardware_exception
    # For wifi and tls/https
    pico_cyw43_arch_lwip_threadsafe_background pico_lwip_mbedtls pico_mbedtls
    # bluetooth
    pico_btstack_ble pico_btstack_classic pico_btstack_cyw43
    # sntp
    pico_lwip_sntp
  )
endFunction()
