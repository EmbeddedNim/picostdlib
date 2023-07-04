set(OUTPUT_NAME test_pico)

add_executable(${OUTPUT_NAME})

picostdlib_sources(${OUTPUT_NAME})

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/test_pico_imports.cmake ${CMAKE_BINARY_DIR}/${OUTPUT_NAME}/imports.cmake COPYONLY)

picostdlib_configure(${OUTPUT_NAME})

# set_target_properties(${OUTPUT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

# Add directory containing this CMakeLists file to include search path.
# This is required so that the lwipopts.h file is found. Other headers
# required for a project can also be placed here.
target_include_directories(${OUTPUT_NAME} PUBLIC
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/../template/csource
)

# Additional libraries
target_link_libraries(${OUTPUT_NAME}
  # For wifi and tls/https
  # pico_cyw43_arch_lwip_threadsafe_background pico_lwip_mbedtls pico_mbedtls
)
# havent gotten sockets to work with freertos yet...
# pico_cyw43_arch_lwip_sys_freertos FreeRTOS-Kernel-Heap3

target_compile_definitions(${OUTPUT_NAME} PRIVATE
  # CYW43_HOST_NAME="PicoW"
  PICO_STDIO_USB_CONNECT_WAIT_TIMEOUT_MS=2000
)

# enable usb output, disable uart output
pico_enable_stdio_usb(${OUTPUT_NAME} 1)
pico_enable_stdio_uart(${OUTPUT_NAME} 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(${OUTPUT_NAME})

# add url via pico_set_program_url
# pico_set_program_url(${OUTPUT_NAME} "")
