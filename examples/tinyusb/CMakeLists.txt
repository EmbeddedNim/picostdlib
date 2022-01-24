cmake_minimum_required(VERSION 3.13)

# initialize the SDK based on PICO_SDK_PATH

# note: this must happen before project()
include(pico_sdk_import.cmake)

project(tinyusb)

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

# add program file(s)
file(GLOB MyCSources *.c)
add_executable(tinyusb)

target_sources(tinyusb PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/../src/usb_descriptors.c
        ${MyCSources}
        )

# Make sure TinyUSB can find tusb_config.h
target_include_directories(tinyusb PUBLIC ${CMAKE_CURRENT_LIST_DIR}/../src)

# pull in our pico_stdlib which pulls in commonly used features
# hardware_adc tinyusb_device tinyusb_board Currently supported.
target_link_libraries(tinyusb pico_stdlib hardware_adc tinyusb_board tinyusb_device)

# Note: since we create a custom tinyusb device, USB stdio must be disabled
pico_enable_stdio_usb(tinyusb 0)
pico_enable_stdio_uart(tinyusb 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(tinyusb)

# add url via pico_set_program_url
pico_set_program_url(tinyusb 1)
